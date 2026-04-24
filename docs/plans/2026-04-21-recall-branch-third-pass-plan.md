# Recall Branch Third Pass Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** recall hunt의 최근 branch 결과를 selected-hunt presentation card와 stage brief card에도 반영한다.

**Architecture:** `CampaignController._build_recall_presentation_cards()`에 `last_hunt_result`를 넘기고, selected hunt와 id가 같을 때 branch summary/override를 선택 카드와 전장 요점 카드에 merge한다.

**Tech Stack:** Godot 4.6, GDScript, CampaignPanel payload, headless SceneTree runners
