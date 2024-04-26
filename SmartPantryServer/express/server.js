import axios from "axios";
import FormData from "form-data";
import { config } from "dotenv";
import express, { json, urlencoded } from "express";
import normalizePort from "normalize-port";
import multer from "multer";
import cors from "cors";
import { Dropbox } from "dropbox";
import fetch from "node-fetch";

config();
const app = express();
const upload = multer();

app.use(express.text());
app.use(cors());
app.use(json());
app.use(urlencoded({ extended: true }));
app.use(upload.single("image"));

const port = normalizePort(process.env.PORT || "3000");

const dbx = new Dropbox({
  clientId: process.env.DROPBOX_CLIENT_ID,
  refreshToken: process.env.DROPBOX_API_KEY,
  fetch: fetch,
});

app.get("/", (req, res) => {
  res.send("Smart Pantry API");
});

app.post("/upload", async (req, res) => {
  try {
    console.log("Uploading");
    let data = JSON.stringify(req.body);
    console.log(data);

    data = data.replace(/\\n/g, "\n");

    const buffer = Buffer.from(data.substring(2, data.length - 5), "utf-8");
    const dropboxDestination = "/logs.txt";
    const result = await dbx.filesUpload({
      path: dropboxDestination,
      contents: buffer,
      mode: { ".tag": "overwrite" },
    });
    return res.status(200).send(result);
  } catch (exception) {
    return res.status(500).json({ error: "Error occured: " + exception });
  }
});

app.post("/get-pantry", async (req, res) => {
  if (!req.file) {
    return res.status(400).json({ error: "No image file provided" });
  }
  if (
    req.file.originalname.endsWith(".jpg") ||
    req.file.originalname.endsWith(".jpeg")
  ) {
    let data = new FormData();
    data.append("file_data", req.file.buffer.toString("base64"));

    let config = {
      method: "post",
      maxBodyLength: Infinity,
      url: "https://api.veryfi.com/api/v8/partner/documents",
      headers: {
        "Content-Type": "multipart/form-data",
        Accept: "application/json",
        "CLIENT-ID": process.env.VERYFI_CLIENT_ID,
        AUTHORIZATION: process.env.VERYFI_API_KEY,
        ...data.getHeaders(),
      },
      data: data,
    };

    try {
      const response = await axios(config);
      const filtered_response = response.data.line_items.filter(
        (e) => e.description != null && e.type == "food"
      );
      let result = [];

      for (var i = 0; i < filtered_response.length; i++) {
        result.push({
          name:
            filtered_response[i].normalized_description != null
              ? filtered_response[i].normalized_description
              : filtered_response[i].description,
          quantity: {
            value:
              filtered_response[i].quantity != null
                ? filtered_response[i].quantity.toString()
                : "1",
            unit:
              filtered_response[i].unit_of_measure != null
                ? filtered_response[i].unit_of_measure
                : "item",
            ttl: 1,
          },
          price:
            filtered_response[i].total != null
              ? filtered_response[i].total.toString()
              : 0,
        });
      }
      return res.status(200).send(result);
    } catch (error) {
      return res.status(400).json(error);
    }
  }
  return res.status(400).json({ error: "File is not a JPG image" });
});

app.get("/get-logs", async (req, res) => {
  const dropboxDestination = "/logs.txt";
  const result = await dbx.filesDownload({
    path: dropboxDestination,
  });
  res.send(result.result.fileBinary.toString());
});

app.listen(port, () => {
  console.log(`Example app listening on port ${port}`);
});
