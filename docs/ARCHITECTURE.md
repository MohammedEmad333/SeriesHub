# Architecture

SeriesHub uses a feature-first Flutter architecture.

## Layers

- presentation: screens, widgets, navigation, player controls
- domain: entities and use-cases
- data: repositories, local cache, API/provider adapters
- providers: isolated catalog/source integrations

## Planned feature modules

- home
- search
- series
- seasons
- episodes
- player
- downloads
- favorites
- history
- settings

## Provider contract

A provider should expose metadata and authorized playback resources without coupling the app UI to a specific service.

Planned capabilities:

- search
- browse
- series details
- seasons
- episodes
- playback variants
- subtitles/audio metadata
