<!-- GENERATED from catalog/properties/properties-object-agent.yaml by pipeline/generate.mjs — DO NOT EDIT. Edit the catalog and run `npm run build`. -->
---
name: properties-object-agent
description: Configurable agent properties
---

Applies to: Agent objects ([object-agent](./object-agent.md))

# GENERAL
Includes [properties-common](./properties-common.md).

## Main program
Marks the object as executable (standalone)
- Type: `boolean`
- Default: `False`

## AI Model
Agent model name; check Supported Chat Models (https://docs.globant.ai/en/wiki?200,Supported+Chat+Models)
- Type: `string`
- Default: `openai/gpt-4.1`

# LLM CONFIGURATION

## Creativity Level (temperature)
Controls predictability; higher values introduce randomness/diversity
- Type: `number`
- Default: `0.5`

## Max Tokens
Controls max tokens in response; higher values allow more detailed answers
- Type: `integer`
- Default: `5000`

# WORKFLOW

## Callable from workflow
Allows agent to be called from a BPD node (see object-business-process)
- Type: `boolean`
- Default: `False`

# NOTES
Use this file to select editable properties, defaults, and valid options for this target.
