/* =========================================================
   CHARLIE CAFE — GLOBAL CONFIGURATION
   ---------------------------------------------------------
   ✔ AWS Region
   ✔ Cognito Config
   ✔ API Gateway Base (PROD)
   ✔ CloudFront Base
========================================================= */

window.CHARLIE_CONFIG = {

    /* ===============================
       🌍 AWS REGION
    =============================== */
    REGION: "us-east-1",

    /* ===============================
       🔑 Secrets Manager Name for RDS
    =============================== */
    rdsSecretName: "CafeDevDBSM",   // Must match your Secrets Manager secret name

    /* ===============================
       🔐 AWS Cognito Configuration
    =============================== */
    USER_POOL_ID: "us-east-1_dEIQZP6zR",
    CLIENT_ID: "35dgk7toqp7q0hpg6pc6bln4e3",
    COGNITO_DOMAIN: "https://us-east-1deiqzp6zr.auth.us-east-1.amazoncognito.com",

    /* ===============================
       🚀 API Gateway (PRODUCTION)
    =============================== */
    API_BASE: "https://1kbgj4vpi9.execute-api.us-east-1.amazonaws.com/prod",

    /* ===============================
       ☁ CloudFront Distribution
    =============================== */
    CLOUDFRONT_BASE: "https://d1mz6k86rbin2a.cloudfront.net"
};
