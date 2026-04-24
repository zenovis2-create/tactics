# Recall Branch Fourth Pass Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** recall branch 결과를 return card와 return scene card의 eyebrow/title에도 반영한다.

**Architecture:** `CampaignController._build_hunt_return_presentation_cards()`에서 `last_hunt_result.branch_summary`와 `return_cutscene_override`를 읽어 eyebrow/title을 분기한다. 데이터 모델 추가는 없다.

**Tech Stack:** Godot 4.6, GDScript, CampaignPanel presentation cards, headless SceneTree runners
