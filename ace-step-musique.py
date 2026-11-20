"""Génère une musique de fond instrumentale avec ACE-Step 1.5 (licence MIT, local, GPU).

Usage :
  ace-step\\.venv\\Scripts\\python.exe ace-step-musique.py "description" sortie.wav [--duree 30] [--bpm 100] [--lm]

description : style en anglais de préférence, ex. "lofi chill beat, soft piano, warm, no vocals"
--lm        : active le modèle de langage (meilleure structure, plus lent, plus de mémoire)
"""
import argparse
import os
import shutil
import sys

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "ace-step")
CWD = os.getcwd()
sys.path.insert(0, ROOT)
os.chdir(ROOT)

from acestep.handler import AceStepHandler  # noqa: E402
from acestep.llm_inference import LLMHandler  # noqa: E402
from acestep.inference import GenerationConfig, GenerationParams, generate_music  # noqa: E402


def main() -> None:
    p = argparse.ArgumentParser()
    p.add_argument("description")
    p.add_argument("sortie")
    p.add_argument("--duree", type=float, default=30)
    p.add_argument("--bpm", type=int, default=None)
    p.add_argument("--lm", action="store_true")
    a = p.parse_args()

    dit = AceStepHandler()
    dit.initialize_service(project_root=ROOT, config_path="acestep-v15-turbo", device="cuda")
    llm = LLMHandler()
    if a.lm:
        llm.initialize(checkpoint_dir=os.path.join(ROOT, "checkpoints"),
                       lm_model_path="acestep-5Hz-lm-0.6B", backend="pt", device="cuda")

    params = GenerationParams(
        task_type="text2music",
        caption=a.description,
        lyrics="[Instrumental]",
        instrumental=True,
        duration=a.duree,
        bpm=a.bpm,
        thinking=a.lm,
        use_cot_caption=a.lm,
        use_cot_metas=a.lm,
        use_cot_language=False,
    )
    config = GenerationConfig(batch_size=1, audio_format="wav")
    out_dir = os.path.join(ROOT, "outputs_tmp")
    res = generate_music(dit, llm, params, config, save_dir=out_dir)
    if not res.success or not res.audios:
        sys.exit(f"Echec : {getattr(res, 'error', res)}")
    shutil.move(res.audios[0]["path"], os.path.join(CWD, a.sortie))
    print(f"OK {a.sortie}")


if __name__ == "__main__":
    main()
