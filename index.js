require("dotenv").config();
const express = require("express");
const bodyParser = require("body-parser");
const cors = require("cors");
const fetch = require("node-fetch"); // Mantemos o require, pois estamos usando v2.x

const app = express();
const PORT = process.env.PORT || 3001;

app.use(cors());
app.use(bodyParser.json());
// Não é necessário, mas não causa problemas: app.use(bodyParser.urlencoded({ extended: false }));


const SQUARE_ACCESS_TOKEN = process.env.SQUARE_ACCESS_TOKEN;
const SQUARE_LOCATION_ID = process.env.SQUARE_LOCATION_ID;

app.post("/process-payment", async (req, res) => {
  const { nonce, amount } = req.body;

  if (!nonce || !amount) {
    return res.status(400).json({ status: "error", message: "Dados inválidos." });
  }

  try {
    const response = await fetch("https://connect.squareup.com/v2/payments", {
      method: "POST",
      headers: {
        "Square-Version": "2023-04-19", // Mantenha a versão que você estava usando
        "Content-Type": "application/json",
        Authorization: `Bearer ${SQUARE_ACCESS_TOKEN}`,
      },
      body: JSON.stringify({
        source_id: nonce,
        idempotency_key: `${Date.now()}-${Math.random()}`,
        amount_money: {
          amount: amount,
          currency: "USD", // Ou a moeda correta, se não for USD
        },
        location_id: SQUARE_LOCATION_ID,
      }),
    });

    const data = await response.json();
    if (response.ok) {
      res.status(200).json({ status: "success", message: "Pagamento processado!", data });
    } else {
      // Melhor tratamento de erros, incluindo detalhes do erro do Square
      console.error("Erro do Square:", data.errors);
      res.status(400).json({ status: "error", message: data.errors[0]?.detail || "Erro no processamento do pagamento." });
    }
  } catch (error) {
    console.error("Erro ao processar pagamento:", error);
    res.status(500).json({ status: "error", message: "Erro interno do servidor" });
  }
});

app.listen(PORT, () => {
  console.log(`Servidor rodando na porta ${PORT}`);
});