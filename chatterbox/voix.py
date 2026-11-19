"""Génère une voix off française avec Chatterbox Multilingual (licence MIT).

Usage :
  .venv\\Scripts\\python.exe voix.py "Texte à dire" sortie.wav [--ref voix_reference.wav]
         [--exag 0.5] [--cfg 0.5] [--lang fr]

--ref   : court enregistrement (10-20 s, voix claire) à imiter. Sans --ref : voix par défaut.
--exag  : expressivité (0.3 calme -> 0.8 très expressif). TikTok : 0.5-0.7.
--cfg   : rythme/fidélité (plus bas = débit plus lent et posé). 0.3-0.5 conseillé.
"""
import argparse
import re

import torch
import torchaudio as ta
from chatterbox.mtl_tts import ChatterboxMultilingualTTS


def phrases(texte: str) -> list[str]:
    # Découpe en phrases : Chatterbox est plus naturel sur des segments courts.
    morceaux = re.split(r"(?<=[.!?…])\s+", texte.strip())
    return [m for m in morceaux if m]


def main() -> None:
    p = argparse.ArgumentParser()
    p.add_argument("texte")
    p.add_argument("sortie")
    p.add_argument("--ref", default=None)
    p.add_argument("--exag", type=float, default=0.5)
    p.add_argument("--cfg", type=float, default=0.5)
    p.add_argument("--lang", default="fr")
    p.add_argument("--pause", type=float, default=0.25, help="silence entre phrases (s)")
    a = p.parse_args()

    device = "cuda" if torch.cuda.is_available() else "cpu"
    model = ChatterboxMultilingualTTS.from_pretrained(device=device)

    silence = torch.zeros(1, int(model.sr * a.pause))
    segments = []
    for ph in phrases(a.texte):
        wav = model.generate(
            ph,
            language_id=a.lang,
            audio_prompt_path=a.ref,
            exaggeration=a.exag,
            cfg_weight=a.cfg,
        )
        segments += [wav.cpu(), silence]
    audio = torch.cat(segments[:-1], dim=1)
    ta.save(a.sortie, audio, model.sr)
    print(f"OK {a.sortie} ({audio.shape[1] / model.sr:.1f} s, {device})")


if __name__ == "__main__":
    main()
