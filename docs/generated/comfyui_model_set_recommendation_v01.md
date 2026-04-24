# ComfyUI Model Set Recommendation V01

## Target

This recommendation is for:

- `/Volumes/AI2/ComfyUI`
- layered 8-direction character generation
- anchor-first image-to-image derivation
- tactical JRPG readability over raw beauty rendering

## Hardware Assumption

Current install target:

- Apple M4
- 24 GB unified memory

This matters because the best model set is not the biggest possible model set.

For this project, the correct priority is:

1. reproducible character identity
2. controllable image-to-image derivation
3. moderate local performance

## Recommendation

Use a **small, disciplined starter set**.

Do **not** begin with:

- many checkpoints
- many LoRAs
- heavy photoreal-first models
- model zoo collection

## Starter Set

### 1. Primary stylized checkpoint

Role:

- main character generation model
- anchor generation
- base body / base outfit / overlay derivation

Requirement:

- SDXL-class stylized model
- anime/JRPG-friendly line and material handling
- good img2img behavior

Recommendation:

- install **one** primary stylized SDXL checkpoint first

Reason:

- this project is not photoreal
- we need readable shapes, controlled costume mass, and face consistency

Suggested placement:

- `/Volumes/AI2/ComfyUI/models/checkpoints/`

### 2. Neutral fallback SDXL checkpoint

Role:

- structural fallback
- comparison baseline when the stylized checkpoint drifts too hard

Recommendation:

- install **one** neutral SDXL base checkpoint

Reason:

- if the stylized model overcommits to costume or ornament, the neutral model is
  useful for correction passes

Suggested placement:

- `/Volumes/AI2/ComfyUI/models/checkpoints/`

### 3. VAE

Role:

- stable decode quality
- more predictable color and edge handling

Recommendation:

- install **one** SDXL-compatible VAE

Suggested placement:

- `/Volumes/AI2/ComfyUI/models/vae/`

### 4. IP-Adapter or identity-reference support

Role:

- preserve same character identity across derivations
- reduce face and silhouette drift between anchor and variants

Recommendation:

- install **one** SDXL-compatible identity/reference-preserving model path

Reason:

- this is one of the main reasons to use ComfyUI at all in this project

Suggested placement:

- `/Volumes/AI2/ComfyUI/models/clip_vision/`
- and any related adapter weights in the model path expected by the chosen workflow

### 5. ControlNet for structure

Minimum controls:

- lineart or canny
- pose or openpose

Role:

- preserve direction and silhouette discipline
- keep 8dir views from mutating too far away from the anchor

Recommendation:

- install **two** SDXL-compatible ControlNet models first:
  - one edge/line model
  - one pose model

Suggested placement:

- `/Volumes/AI2/ComfyUI/models/controlnet/`

### 6. Upscaler

Role:

- cleanup after generation
- optional resolution lift before Krita cleanup

Recommendation:

- install **one** conservative upscaler only

Reason:

- this project needs readable edges more than glossy enhancement

Suggested placement:

- `/Volumes/AI2/ComfyUI/models/upscale_models/`

## What To Avoid At First

### Avoid `Flux-first`

Reason:

- too heavy for the initial local workflow goal
- not the best first tool for a controlled layered JRPG character pipeline
- speed and workflow complexity are worse than needed for our first slice

### Avoid many character LoRAs immediately

Reason:

- they often create style lock-in before the base contract is stable
- they can hide drift instead of solving it

### Avoid photoreal checkpoints

Reason:

- the project style wants tactical readability
- photoreal models tend to fight clean layer separation

## Practical Minimum Pack

The first practical pack should be:

1. one stylized SDXL checkpoint
2. one neutral SDXL checkpoint
3. one SDXL VAE
4. one identity-preserving reference module
5. one line/edge ControlNet
6. one pose ControlNet
7. one upscaler

That is enough to start:

- `Rian identity_anchor`
- `Rian base_body`
- `Rian base_outfit`
- `Rian weapon_overlay`
- `Rian upper_armor_overlay`

without turning the setup into model chaos.

## Project-Fit Conclusion

For this project, ComfyUI should be used as:

- a reproducible character derivation backend

not as:

- an endless model playground

The right first move is a narrow starter set built around:

- stylized SDXL
- image-to-image consistency
- structural control

not raw model quantity.
