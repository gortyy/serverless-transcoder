import argparse
from zipfile import ZipFile

from path import Path
from python_terraform import Terraform, IsFlagged


def zip_lambda_function(src, dst):
    dst = Path(dst).abspath()
    with Path(src), ZipFile(dst, "w") as lambda_zip:
        for file in Path(".").walk():
            lambda_zip.write(file)


def parse_args():
    parser = argparse.ArgumentParser()
    action = parser.add_mutually_exclusive_group()
    action.add_argument("--apply", action="store_true")
    action.add_argument("--destroy", action="store_true")
    parser.add_argument("--workdir")
    parser.add_argument("--tfvars")
    parser.add_argument("--lambdas")

    return parser.parse_args()


if __name__ == "__main__":
    args = parse_args()

    tf = Terraform(working_dir=args.workdir)
    tf.init()

    if args.apply:
        for lf in args.lambdas.split(","):
            name = lf.split("/")[-1].split(".")[0]
            zip_lambda_function(lf, f"{args.workdir}/{name}.zip")

        tf.apply(
            no_color=IsFlagged,
            refresh=False,
            var_file=args.tfvars,
            skip_plan=True,
            capture_output=False,
        )

    elif args.destroy:
        tf.destroy(
            no_color=IsFlagged, var_file=args.tfvars, capture_output=False
        )
    else:
        raise ValueError("Action not specified.")
