# Yankee Horn Studio update

- Eight voices: the existing four plus synthesized brass, crystal, retro pulse and velvet. New voices use independent harmonic profiles, not additional recorded samples.
- 16/32/64-step editor, reproducible scale-based phrase generation, reverse, rotate, half-pattern copy and one-level note undo. Shortening preserves the prior pattern through undo.
- Swing, gate, transpose, fixed-interval duet and stereo cross-delay.
- WAV, AIFF and M4A export. Export includes studio delay; playback reverb and background bike audio are not included. Echo tails are cut at the pattern boundary with a short fade.
- Save/restore notes, length, tempo, voice, studio settings, grit and human feel. Legacy melody JSON still loads.
- Scrollable editing controls with playback/stop always visible.
- Zero-preserving saturation, DC removal, output headroom and edge fades. Studio parameters are copied under a lock for background rendering.

Validation: production render/encode tests for all four new voices, timing and persistence regression tests, and iOS simulator build. Hardware playback, MIDI devices and acoustic quality have not been verified on an iPhone/iPad. This branch has not been submitted to App Review.
