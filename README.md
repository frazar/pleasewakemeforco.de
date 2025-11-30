# [pleasewakemeforco.de](https://pleasewakemeforco.de/)

The `docs` folder of the `main` branch of this repo is published to the
[pleasewakemeforco.de](https://pleasewakemeforco.de/) website using [GitHub Pages](https://docs.github.com/en/pages).
The `docs` folder contains a static site generated with [MkDocs](https://www.mkdocs.org/) and the 
[Material theme for MkDocs](squidfunk.github.io/mkdocs-material/).


# Development

## Intial setup (1st time only)

The first time you checkout the repository, setup your environment by:

1.  Installing `uv` following [the official docs](https://docs.astral.sh/uv/getting-started/installation/)
2.  Checkout this repository and move into its directory
3.  Create a dedicated virtual environment

    ```bash
    uv .venv
    ```

## Usual workflow

Then, every time you're developing on the repository

1.  Ensure the virtual environment is up-to-date

    ```bash
    uv sync --frozen
    ```

2.  Now you can show a live preview of your changes accessible at [http://127.0.0.1:8000/](http://127.0.0.1:8000/)

    ```bash
    uv run --frozen mkdocs serve
    ```

    or rebuild the `docs/` folder with

    ```bash
    uv run --frozen mkdocs build
    ```
