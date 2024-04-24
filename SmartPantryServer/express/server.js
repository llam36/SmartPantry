import axios from "axios";
import FormData from "form-data";
import { config } from "dotenv";
import express, { json, urlencoded } from "express";
import normalizePort from "normalize-port";
import multer from "multer";
import cors from "cors";

config();
const app = express();
const upload = multer();

app.use(cors());
app.use(json());
app.use(urlencoded({ extended: true }));
app.use(upload.single("image"));

const port = normalizePort(process.env.PORT || "3000");

app.get("/", (req, res) => {
  res.send("Smart Pantry API");
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
        (e) => e.description != null
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

app.listen(port, () => {
  console.log(`Example app listening on port ${port}`);
});
