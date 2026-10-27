# [pleasewakemeforco.de](https://pleasewakemeforco.de/)

The `docs` folder of the `main` branch of this repo is published to the
[pleasewakemeforco.de](https://pleasewakemeforco.de/) website using [GitHub Pages](https://docs.github.com/en/pages).
The `docs` folder contains a static site generated with [Zensical](https://zensical.org/).

# Development

## Initial setup (1st time only)

When you set up the development environment for the first time:

1.  Install `uv` following [the official docs](https://docs.astral.sh/uv/getting-started/installation/)
2.  Clone this repository and move into its directory
3.  Create a dedicated virtual environment

    ```bash
    uv venv
    ```

## Normal workflow

To work on the repository

1.  Ensure the virtual environment is up-to-date

    ```bash
    uv sync --frozen
    ```

2.  Now you can show a live preview of your changes accessible at [http://127.0.0.1:8000/](http://127.0.0.1:8000/)

    ```bash
    uv run --frozen zensical serve --strict
    ```

    or rebuild the `docs/` folder with

    ```bash
    uv run --frozen zensical build
    ```

## Publishing

1.  Switch to main and build the website

    ```bash
    git switch main
    rm -rf site
    uv run --frozen zensical build --strict
    ```

2.  Switch to the "prod" branch and delete the older version of the site

    ```bash
    git switch prod
    git rm -rf docs
    ```

3.  Add the new version of the site and commit it

    ```bash
    mv site docs
    git add docs
    git commit -m "My message"
    git push
    ```
