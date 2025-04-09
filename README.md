# 🌐 SolaceNet Dashboard

**Real-Time Financial Network Visualization for Sovereign, Interbank, and CBDC Ecosystems**

---

## 📦 Features

- 🌍 Trust Topology, Interbank Flowchart, SolaceNet Integration Maps
- ⚡ Real-time visualization using Recharts Sankey
- 🧪 Vitest + React Testing Library
- 🚀 CI/CD deployment to Azure Static Web Apps
- 🧳 Portable via GitHub Codespaces
- 📁 JSON-driven diagrams, easily extensible

---

## 🛠️ Setup

```bash
git clone https://github.com/YOUR_ORG/solacenet-dashboard.git
cd solacenet-dashboard
npm install
npm run dev
```

---

## ✅ Testing

```bash
npm run test
```

To open the test UI:

```bash
npx vitest --ui
```

---

## ☁️ Deployment

### 1. Create Azure Static Web App
- Use Azure Portal or Bicep template (`infra/solacenet.bicep`)

### 2. Add GitHub Secret
- `AZURE_STATIC_WEB_APPS_API_TOKEN` from Azure deployment credentials

---

## 📁 Project Structure

```
solacenet-dashboard/
├── public/
├── src/
│   ├── components/
│   ├── data/
│   ├── diagrams/
│   ├── tests/
│   └── App.tsx
├── azure-static-web-apps.yml
├── vite.config.ts
├── tsconfig.json
├── README.md
└── .devcontainer/
```

---

## 🧩 Extendable Features (Recommended)

- [ ] 🌐 Jurisdictional Filters (US, ZA, HK, etc.)
- [ ] 🔗 ASN/LEI Overlay on Sankey Nodes
- [ ] 📊 Modalities Matrix (Legacy + Modern Transfers)
- [ ] 🧾 On-chain Compliance View (ISO 20022, AML, KYC)

---

## 🧠 Authors & Legal

- **Maintained by:** Roy Walker, PLLC | P.C. Walker, Esq.
- **Stakeholders:** OMDN, Atlantic Partners Asia, Solace Bank Group
- **Compliance Layer:** Defi Oracle Meta (BIS Innovations Division)

Licensed for public-benefit financial infrastructure use.