# Charlie Cafe - EC2

### 🚀 1️⃣ What You Are Building (CloudFormation Stack)

#### Your stack will create:

✅ EC2 instance (CafeDevWebServer)

✅ Security Group (SSH + HTTP)

✅ User Data (your full bootstrap script)

✅ Optional: KeyPair input

✅ Runs automatically at launch

### 📄 2️⃣ CloudFormation Template (FULL YAML)

#### Copy this into a file: 

[cafe-ec2.yaml](./cafe-ec2.yaml)

### ⚠️ IMPORTANT (VERY IMPORTANT)

- ### 🔴 Replace AMI ID

#### Amazon Linux 2023 AMI is region-specific

- Go to: EC2 → Launch Instance → Copy AMI ID

- Replace:

```
ImageId: ami-xxxxxxxx
```

### 🚀 3️⃣ How to Deploy (Step-by-Step)

- ### Option A — AWS Console (Easiest)

- Go to: 👉 CloudFormation

- Click: 👉 Create Stack → With new resources

- Upload: 👉 cafe-ec2.yaml

- Fill parameters: KeyPairName → your key

- VpcId → Dev VPC

- SubnetId → Public subnet

- MyIP → your IP (example: 39.x.x.x/32)

- Click: 👉 Next → Create Stack

- ### Option B — AWS CLI (DevOps way)

```
aws cloudformation create-stack \
  --stack-name cafe-dev-stack \
  --template-body file://cafe-ec2.yaml \
  --parameters \
    ParameterKey=KeyPairName,ParameterValue=YOUR_KEY \
    ParameterKey=VpcId,ParameterValue=YOUR_VPC \
    ParameterKey=SubnetId,ParameterValue=YOUR_SUBNET \
    ParameterKey=MyIP,ParameterValue=YOUR_IP/32 \
  --capabilities CAPABILITY_NAMED_IAM
```

### 🧠 4️⃣ What You Just Achieved (IMPORTANT)

#### You have now:

✅ Converted manual EC2 setup → Infrastructure as Code

✅ Automated full server provisioning

✅ Embedded DevOps bootstrap (Docker + tools)

✅ Ready for CI/CD integration

### 🔥 5️⃣ Next Upgrade (VERY IMPORTANT FOR YOUR LAB)

#### Since you're building a real DevOps project, next steps should be:

- Add: 

    IAM Role for EC2 (ECR + S3 access)

- Add: 

    Auto Scaling Group

- Replace EC2 with:

    ECS (you already planning this 👍)

- Add:

    ALB integration

---


