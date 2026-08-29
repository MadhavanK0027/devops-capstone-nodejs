# End-to-End DevOps Pipeline for a Node.js Web Application

## Project Overview

This project demonstrates a complete end-to-end DevOps CI/CD pipeline for a Node.js web application.

The project integrates GitHub, Jenkins, Docker, Docker Hub, AWS EC2, Prometheus, Grafana, Node Exporter, Bash scripting, and Cron automation.

The pipeline automatically builds, tests, containerizes, pushes, and deploys the application to an AWS EC2 server. The infrastructure is monitored using Prometheus and Grafana, while Bash scripts and Cron automate application log backups and cleanup.

---

## Architecture

```text
Developer
    |
    | Git Push
    v
GitHub Repository
    |
    | Webhook / Jenkins Trigger
    v
Jenkins EC2
    |
    +--> npm install
    |
    +--> npm test
    |
    +--> Docker Build
    |
    +--> Docker Hub Push
    |
    | SSH Deployment
    v
App EC2
    |
    +--> Docker Container
    |       |
    |       +--> Node.js Application
    |       +--> Port 3000
    |
    +--> Node Exporter :9100
            |
            v
       Prometheus :9090
            |
            v
        Grafana :3000

Bash + Cron
    |
    +--> Daily application log backup
    |
    +--> Weekly old backup cleanup
```

---

## Tech Stack

| Category           | Technology    |
| ------------------ | ------------- |
| Source Control     | Git           |
| Repository         | GitHub        |
| CI/CD              | Jenkins       |
| Application        | Node.js       |
| Containerization   | Docker        |
| Container Registry | Docker Hub    |
| Cloud              | AWS           |
| Compute            | Amazon EC2    |
| Operating System   | Ubuntu        |
| Monitoring         | Prometheus    |
| Visualization      | Grafana       |
| Metrics Exporter   | Node Exporter |
| Automation         | Bash + Cron   |

---

## Project Structure

```text
devops-capstone-nodejs/
│
├── app/
│   ├── server.js
│   ├── package.json
│   └── package-lock.json
│
├── Scripts/
│   ├── backup_logs.sh
│   └── cleanup_logs.sh
│
├── Dockerfile
├── Jenkinsfile
├── README.md
└── .gitignore
```

---

## Application

The application is a simple Node.js web application that runs on port `3000`.

### Local Setup

Clone the repository:

```bash
git clone https://github.com/MadhavanK0027/devops-capstone-nodejs.git
cd devops-capstone-nodejs
```

Navigate to the application directory:

```bash
cd app
```

Install dependencies:

```bash
npm install
```

Start the application:

```bash
npm start
```

The application will be available at:

```text
http://localhost:3000
```

---

## Testing

Run:

```bash
npm test
```

The project contains an automated test command that verifies the application pipeline test stage.

---

## Docker

### Build Docker Image

From the project root:

```bash
docker build -t maddy0027/devops-node-app:latest .
```

### Run Container

```bash
docker run -d \
  --name devops-node-app \
  -p 3000:3000 \
  --restart unless-stopped \
  maddy0027/devops-node-app:latest
```

Check the running container:

```bash
docker ps
```

---

## Docker Hub

The Jenkins pipeline builds and pushes Docker images to Docker Hub.

Repository:

```text
maddy0027/devops-node-app
```

Example image:

```text
maddy0027/devops-node-app:6
```

---

## Jenkins CI/CD Pipeline

The Jenkins pipeline contains the following stages:

### 1. Checkout

Jenkins checks out the latest source code from GitHub.

### 2. Install Dependencies

```bash
cd app
npm install
```

### 3. Test

```bash
cd app
npm test
```

### 4. Build Docker Image

Jenkins creates the Docker image:

```bash
docker build -t maddy0027/devops-node-app:<BUILD_NUMBER> .
```

### 5. Push to Docker Hub

Jenkins authenticates with Docker Hub and pushes the generated image.

Example:

```text
maddy0027/devops-node-app:6
```

### 6. Deploy to App EC2

Jenkins connects to the application EC2 server using SSH.

The deployment performs:

```bash
docker pull maddy0027/devops-node-app:<BUILD_NUMBER>
docker stop devops-node-app || true
docker rm devops-node-app || true
docker run -d \
  --name devops-node-app \
  -p 3000:3000 \
  --restart unless-stopped \
  maddy0027/devops-node-app:<BUILD_NUMBER>
```

### 7. Verify Deployment

Jenkins verifies that the Docker container is running:

```bash
docker ps --filter name=devops-node-app
```

---

## Deployment

The Node.js application is deployed inside a Docker container on an AWS EC2 instance.

Application port:

```text
3000
```

Example deployment URL:

```text
http://44.197.131.111:3000
```

> The public IP may change if the EC2 instance is stopped and started without an Elastic IP.

---

## Monitoring

### Node Exporter

Node Exporter collects system-level metrics from the application EC2 server.

It runs on:

```text
Port: 9100
```

Verify:

```bash
sudo systemctl status node_exporter
```

Test metrics:

```bash
curl http://localhost:9100/metrics
```

---

## Prometheus

Prometheus collects metrics from Node Exporter.

Prometheus runs on:

```text
Port: 9090
```

Verify:

```bash
sudo systemctl status prometheus
```

Check readiness:

```bash
curl http://localhost:9090/-/ready
```

---

## Grafana

Grafana is used to visualize infrastructure metrics collected by Prometheus.

Grafana runs on:

```text
Port: 3000
```

The dashboard monitors:

* CPU Usage
* Memory Usage
* Disk Usage
* Network Traffic

---

## Alerting

A Grafana alert was configured for high CPU usage.

### Alert Condition

```text
CPU Usage > 80%
```

### Evaluation Duration

```text
5 minutes
```

The alert was tested using `stress-ng` to generate CPU load.

Example:

```bash
stress-ng --cpu 2 --timeout 10m
```

After the CPU load test, the alert returned to the normal state once CPU usage decreased.

---

## Bash and Cron Automation

The project includes Bash scripts for application log backup and cleanup.

### Backup Script

File:

```text
Scripts/backup_logs.sh
```

The script collects Docker application logs and creates a compressed `.tar.gz` backup.

Backup location on the EC2 server:

```text
/home/ubuntu/capstone-backups/
```

Example:

```text
app_logs_2026-08-29_18-43-02.tar.gz
```

### Cleanup Script

File:

```text
Scripts/cleanup_logs.sh
```

The cleanup script removes backup files older than seven days.

---

## Cron Jobs

The following Cron jobs automate the scripts.

### Daily Backup

```cron
0 1 * * * /home/ubuntu/scripts/backup_logs.sh >> /home/ubuntu/scripts/backup.log 2>&1
```

This runs every day at 1:00 AM.

### Weekly Cleanup

```cron
0 2 * * 0 /home/ubuntu/scripts/cleanup_logs.sh >> /home/ubuntu/scripts/cleanup.log 2>&1
```

This runs every Sunday at 2:00 AM.

Verify Cron configuration:

```bash
crontab -l
```

Verify Cron service:

```bash
sudo systemctl status cron
```

---

## Challenges and Solutions

### 1. Docker Port Conflict

The application initially encountered a port conflict on port `3000`.

**Solution:** The existing container/process was identified and stopped before starting the new container.

---

### 2. Node Exporter Service Issue

Node Exporter initially required service configuration and permission corrections.

**Solution:** A dedicated `node_exporter` system user and systemd service were configured.

Node Exporter was then verified using:

```bash
sudo systemctl status node_exporter
```

and:

```bash
curl http://localhost:9100/metrics
```

---

### 3. Prometheus Connectivity

Prometheus and Node Exporter were running on separate EC2 instances, so direct connectivity initially failed.

**Solution:** Network connectivity and the required EC2 security-group configuration were checked and corrected.

---

### 4. Grafana Installation – Disk Space

Grafana installation initially failed because the EC2 root volume had insufficient free space.

The root filesystem was approximately 98% full.

**Solution:** Disk usage was investigated, unnecessary files were cleaned, and the EBS/root volume was expanded before completing the Grafana installation.

---

### 5. Automated Deployment

The application needed to be automatically updated on the App EC2 server after a successful Jenkins build.

**Solution:** Jenkins was configured to SSH into the App EC2 server, pull the new Docker image, remove the old container, and start the new container.

---

## Pipeline Result

A successful Jenkins execution completed the following stages:

```text
Checkout                 SUCCESS
Install Dependencies     SUCCESS
Test                     SUCCESS
Build Docker Image       SUCCESS
Push to Docker Hub       SUCCESS
Deploy to App Server     SUCCESS
Verify Deployment        SUCCESS
```

The pipeline finished with:

```text
Finished: SUCCESS
```

---

## Deliverables

### Source Code

GitHub:

```text
https://github.com/MadhavanK0027/devops-capstone-nodejs
```

### Docker Image

```text
maddy0027/devops-node-app
```

### Deployment

```text
http://44.197.131.111:3000
```

### Monitoring

Prometheus and Grafana are configured on the monitoring EC2 server.

---

## Learning Outcomes

This project provided practical experience with:

* Git and GitHub
* Linux administration
* Jenkins CI/CD
* Docker containerization
* Docker Hub
* AWS EC2
* SSH-based deployment
* Prometheus monitoring
* Grafana dashboards
* Node Exporter
* Bash scripting
* Cron automation
* Infrastructure troubleshooting
* Continuous delivery concepts

---

## Conclusion

This project demonstrates a complete DevOps workflow from source-code management to automated deployment and infrastructure monitoring.

A developer can push code to GitHub, Jenkins automatically builds and tests the application, creates and pushes a Docker image to Docker Hub, deploys the new image to an AWS EC2 server, and verifies the running container.

Prometheus and Grafana provide infrastructure monitoring and alerting, while Bash and Cron automate application log backups and cleanup.

The project therefore demonstrates an end-to-end continuous delivery pipeline using commonly used DevOps tools and AWS infrastructure.
