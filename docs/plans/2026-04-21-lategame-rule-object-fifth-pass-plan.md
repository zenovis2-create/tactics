# Late-Game Rule Object Fifth Pass Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** late-game control object가 objective/state surface를 더 직접적으로 바꾸도록 만들고 headless runners로 검증한다.

**Architecture:** `battle_controller.gd`에서 object interaction 시 기존 relief flag 외에 stronger surface flag를 남기고, 필요하면 HUD transition reason payload를 보강한다. 새 시스템은 추가하지 않는다.

**Tech Stack:** Godot 4.6, GDScript, StageData runtime flags, headless SceneTree runners
