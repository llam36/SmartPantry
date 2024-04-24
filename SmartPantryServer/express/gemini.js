import { config } from "dotenv";
import express, { json, urlencoded } from "express";
import normalizePort from "normalize-port";
import multer from "multer";
import cors from "cors";
import {
  GoogleGenerativeAI,
  HarmBlockThreshold,
  HarmCategory,
} from "@google/generative-ai";

config();
const app = express();
const upload = multer();

app.use(cors());
app.use(json());
app.use(urlencoded({ extended: true }));
app.use(upload.single("image"));

const port = normalizePort(process.env.PORT || "3000");

const safetySettings = [
  {
    category: HarmCategory.HARM_CATEGORY_HARASSMENT,
    threshold: HarmBlockThreshold.BLOCK_NONE,
  },
  {
    category: HarmCategory.HARM_CATEGORY_HATE_SPEECH,
    threshold: HarmBlockThreshold.BLOCK_NONE,
  },
  {
    category: HarmCategory.HARM_CATEGORY_SEXUALLY_EXPLICIT,
    threshold: HarmBlockThreshold.BLOCK_NONE,
  },
  {
    category: HarmCategory.HARM_CATEGORY_DANGEROUS_CONTENT,
    threshold: HarmBlockThreshold.BLOCK_NONE,
  },
];

const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);
const model = genAI.getGenerativeModel({
  model: "gemini-pro-vision",
  safetySettings,
});

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
    const prompt = `Parse this receipt and return a list of json with the following schema
      [{
        name: name of food item and no abbreviation (type: string),
        quantity: {
            value: quantity or weight (type: string),
            unit: item for non-weight quantity or a weight unit found on receipt (type: string),
            ttl: storage time of the food item with same or similar name in days by usda, if not found then give the general recommendation shelf life in days (type: integer)
        },
        price: price of each food item with no unit (type: string),
    }]
      This schema must be honored at all time without fail.
      List each food item as a separate json element. 
      Take into account discount when calculating price.
      Return only the json
      Include only final result for all fields
      Make sure the result is in a list format
      Make sure the result does not contain newline symbol`;
    const image = {
      inlineData: {
        data: req.file.buffer.toString("base64"),
        mimeType: "image/jpeg",
      },
    };
    const result = await model.generateContent([prompt, image]);
    try {
      const resultFormatted = JSON.parse(result.response.text().trim());
      console.log(resultFormatted);
      return res.status(200).send(resultFormatted);
    } catch (e) {
      return res.status(422).json({ error: e.message });
    }
  }
  return res.status(400).json({ error: "File is not a JPG image" });
});

app.listen(port, () => {
  console.log(`Example app listening on port ${port}`);
});
