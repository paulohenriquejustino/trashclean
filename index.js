const express = require('express');
const bodyParser = require('body-parser');
const squareConnect = require('square-connect');

const app = express();
app.use(bodyParser.json());

const accessToken = 'EAAAl5TAZRTbCN27reS7UQNmiHNt0dn9Qo3Cx7Fya7K0IGXyhC8Sn-2UKoS2Pcdy';
const locationId = 'LSB0H89DCVKPH';

const defaultClient = squareConnect.ApiClient.instance;
defaultClient.basePath = 'https://connect.squareup.com/v2/payments';
const oauth2 = defaultClient.authentications['oauth2'];
oauth2.accessToken = accessToken;

const paymentsApi = new squareConnect.PaymentsApi();
const subscriptionsApi = new squareConnect.SubscriptionsApi();
const customersApi = new squareConnect.CustomersApi();

// 📌 1️⃣ Pagamento Único (Cartão de Crédito)
app.post('/process-payment', async (req, res) => {
  const { nonce, amount, currency } = req.body;

  const requestBody = {
    source_id: nonce,
    amount_money: {
      amount: amount,
      currency: currency,
    },
    idempotency_key: require('crypto').randomBytes(12).toString('hex'),
  };

  try {
    const response = await paymentsApi.createPayment(requestBody);
    res.json({ status: 'success', data: response });
  } catch (error) {
    const errorMessage = error.response ? JSON.stringify(error.response.data) : error.message;
    res.status(500).json({ status: 'error', message: errorMessage });
  }
});

// 📌 2️⃣ Criar Cliente no Square (Necessário para assinatura)
app.post('/create-customer', async (req, res) => {
  const { email, given_name, family_name } = req.body;

  const customerData = {
    given_name,
    family_name,
    email_address: email,
    idempotency_key: require('crypto').randomBytes(12).toString('hex'),
  };

  try {
    const response = await customersApi.createCustomer(customerData);
    res.json(response);
  } catch (error) {
    const errorMessage = error.response ? JSON.stringify(error.response.data) : error.message;
    res.status(500).json({ status: 'error', message: errorMessage });
  }
});

// 📌 3️⃣ Criar Assinatura
app.post('/create-subscription', async (req, res) => {
  const { customerId, planId } = req.body;

  const subscriptionData = {
    customer_id: customerId,
    location_id: locationId,
    plan_id: planId,
    idempotency_key: require('crypto').randomBytes(12).toString('hex'),
  };

  try {
    const response = await subscriptionsApi.createSubscription(subscriptionData);
    res.json({ status: 'success', data: response });
  } catch (error) {
    const errorMessage = error.response ? JSON.stringify(error.response.data) : error.message;
    res.status(500).json({ status: 'error', message: errorMessage });
  }
});

const PORT = process.env.PORT || 3001;
app.listen(PORT, () => console.log(`Servidor rodando na porta ${PORT}`));
