# [pleasewakemeforco.de](https://pleasewakemeforco.de/)

The `docs` folder of the `main` branch of this repo is published to the
[pleasewakemeforco.de](https://pleasewakemeforco.de/) website using [GitHub Pages](https://docs.github.com/en/pages).
The `docs` folder contains a static site generated with [MkDocs](https://www.mkdocs.org/) and the 
[Material theme for MkDocs](https://squidfunk.github.io/mkdocs-material/).


# Development

## Intial setup (1st time only)

When you set up the development environment for the first time:

1.  Install `uv` following [the official docs](https://docs.astral.sh/uv/getting-started/installation/)
2.  Install the system dependencies used for media optimization required for the `optimize` plugin of `mkdocs-material` as described in [the official docs](https://squidfunk.github.io/mkdocs-material/plugins/requirements/image-processing/#cairo-graphics).
3.  Clone this repository and move into its directory
4.  Create a dedicated virtual environment

    ```bash
    uv .venv
    ```

## Normal workflow

To work on the repository

1.  Ensure the virtual environment is up-to-date

    ```bash
    uv sync --frozen
    ```

2.  Now you can show a live preview of your changes accessible at [http://127.0.0.1:8000/](http://127.0.0.1:8000/)

    ```bash
    uv run --frozen mkdocs serve --livereload --watch-theme --watch src --watch mkdocs.yml
    ```

    or rebuild the `docs/` folder with

    ```bash
    uv run --frozen mkdocs build
    ```
