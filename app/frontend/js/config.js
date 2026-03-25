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
    USER_POOL_ID: "us-east-1_IIxvGn6hl",
    CLIENT_ID: "3aag3bskuclv4t4rq2n6dai8uq",
    COGNITO_DOMAIN: "https://us-east-1iixvgn6hl.auth.us-east-1.amazoncognito.com",

    /* ===============================
       🚀 API Gateway (PRODUCTION)
    =============================== */
    API_BASE: "https://1kbgj4vpi9.execute-api.us-east-1.amazonaws.com/prod",

    /* ===============================
       ☁ CloudFront Distribution
    =============================== */
    CLOUDFRONT_BASE: "https://d83g7gxgj9s8w.cloudfront.net"
};
