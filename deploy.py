import argparse
import subprocess as sp
from zipfile import ZipFile

from python_terraform import Terraform, IsFlagged


def zip_lambda_function(src, dst):
    with ZipFile(dst, "w") as lambda_zip:
        lambda_zip.write(src)


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

        return_code, stdout, stderr = tf.apply(
            no_color=IsFlagged,
            refresh=False,
            var_file=args.tfvars,
            skip_plan=True,
        )

    elif args.destroy:
        return_code, stdout, stderr = tf.destroy(
            no_color=IsFlagged, var_file=args.tfvars,
        )
    else:
        raise ValueError("Action not specified.")

    print(return_code)
    print(stdout)
    print(stderr)
