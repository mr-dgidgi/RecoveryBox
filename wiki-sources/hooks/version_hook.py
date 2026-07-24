import os


def on_page_markdown(markdown, *, page, config, **kwargs):
    version_file = os.path.join(
        os.path.dirname(config.config_file_path), '..', 'VERSION'
    )
    with open(version_file) as f:
        version = f.read().strip()
    return markdown.replace('{{ rb_version }}', version)
