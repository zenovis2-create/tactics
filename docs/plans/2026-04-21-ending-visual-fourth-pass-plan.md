# Ending Visual Fourth Pass Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** ending/credits overlay에 section progression pip row를 추가하고, ending type/credits index에 맞춰 active state를 갱신한다.

**Architecture:** `Main.tscn`에 small pip rows를 추가하고, `main.gd`가 ending type과 credits section index에 따라 pip 색을 업데이트한다. 기존 sigil/progress label은 유지한다.

**Tech Stack:** Godot 4.6, `.tscn`, GDScript, headless SceneTree runners
