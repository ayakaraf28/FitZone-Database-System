# FitZone-Database-System
# FitZone Database

## 📌 Overview

FitZone is a **fitness center management database** built using **PostgreSQL**.

The project manages members, sessions, bookings, ratings, comments, and loyalty points while applying database concepts such as **relationships, functions, triggers, validation, and audit logging**.

## 🗂️ Main Tables

* **Members** – Stores member information and loyalty points.
* **Sessions** – Stores available fitness sessions.
* **Booking** – Connects members with sessions and stores booking details, ratings, and comments.
* **Booking Audit Log** – Records changes made to bookings.

## ⚙️ Main Triggers

* **Rating Validation:** Ensures ratings are between **1 and 5**.
* **Rating Business Rule:** Prevents changing a rating after it has already been submitted.
* **Audit Trigger:** Logs `INSERT`, `UPDATE`, and `DELETE` operations on bookings.
* **Loyalty Points Trigger:** Increases a member's loyalty points by **1** when they submit a rating for the first time, with a maximum of **5 points**.

## 🛠️ Technologies

* PostgreSQL
* SQL
* PL/pgSQL

## 🎯 Project Goal

The goal of this project is to demonstrate practical database design, SQL queries, functions, triggers, validation rules, business logic, and audit tracking using PostgreSQL.
