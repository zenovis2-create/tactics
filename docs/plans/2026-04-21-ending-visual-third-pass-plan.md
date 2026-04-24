# Ending Visual Third Pass Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** ending/credits overlay의 full-screen fade가 ending type과 credits section에 따라 다르게 tint되도록 만들고 headless runner로 검증한다.

**Architecture:** `Main.tscn`의 기존 fade `ColorRect`를 재사용하고 `main.gd`가 ending type / credits section index에 따라 색을 갱신한다. 텍스트와 accent 로직은 유지한다.

**Tech Stack:** Godot 4.6, `.tscn`, GDScript, headless SceneTree runners
