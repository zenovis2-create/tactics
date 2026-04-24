# Ending Visual Second Pass Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** ending overlay에 결말 sigil을, credits overlay에 section progress를 추가하고 headless runner로 검증한다.

**Architecture:** `Main.tscn`에 소형 label 2개를 추가하고, `main.gd`가 ending type과 credits section index에 따라 값을 갱신한다. 기존 텍스트/eyebrow/label 흐름은 유지한다.

**Tech Stack:** Godot 4.6, `.tscn`, GDScript, headless SceneTree runners
