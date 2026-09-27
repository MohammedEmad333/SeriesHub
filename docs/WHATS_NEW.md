# What's New

## 0.9.0+9

- Added the external SeriesHub Providers package pinned to a known commit.
- Added WatanFlix as the first external source.
- Added a provider adapter so external source models stay isolated from app UI models.
- Added a source selector on the Home screen.
- Added safe handling when a provider has metadata/episodes but no direct playback resource.
- Added adapter tests for series, seasons, episodes, and playback mapping.

## 0.8.0+8

- Added a GitHub Actions Android build pipeline.
- Android platform files are generated automatically during the build.
- Release APKs are built from main and manual workflow runs.
- APK output is uploaded as a downloadable GitHub Actions artifact.
- The Android package namespace is generated under com.mohammedemad333.serieshub.
- Tests run before producing the APK artifact.

## 0.7.0+7

- Bottom navigation is now a persistent app shell instead of stacking screens.
- Home, Search, Favorites, and History keep their tab position.
- Favorites and History items now open series details.
- Library rows now show richer metadata.
- Added automated tests for favorites, history, and watch progress persistence.
- CI now runs flutter test on every pull request.

## 0.6.0+6

- Advanced search filters for language, country, genre, and year.
- Search sorting by relevance, rating, newest, or oldest.
- Search now matches titles, descriptions, genres, and countries.
- Series details show country, language, genres, year, and rating.
- The first season loads automatically.
- Episode rows show saved watch progress.
- Continue Watching cards now resume the episode directly in the player.
- Mock catalog expanded with richer metadata and multiple seasons.

## 0.5.0+5

- Favorites now persist after closing and reopening the app.
- Watch history is stored locally and restored at startup.
- Episode playback progress is persisted locally.
- Continue Watching survives app restarts.
- Watch history is capped at the latest 100 series.

## 0.4.0+4

- Swipe on the left side of the player to adjust app brightness.
- Swipe on the right side to adjust system media volume.
- On-screen percentage overlay while adjusting brightness or volume.
- Audio-track metadata and selector foundation.
- Subtitle-track metadata and selector foundation.
- Player controls remain compatible with fullscreen, touch lock, quality switching, speed controls, and auto-next.

## 0.3.0+3

- Fullscreen video playback.
- Touch-lock mode.
- Double-tap to seek backward or forward 10 seconds.
- Playback speed selector.
- Press and hold for temporary 2x playback.
- Automatic episode completion tracking.
- Automatic playback of the next episode.
- Safer watch-progress persistence.
