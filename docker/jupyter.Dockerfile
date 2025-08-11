FROM quay.io/jupyter/pytorch-notebook:latest

# System-level installs as root
RUN conda install -y -c conda-forge jupyterlab-lsp python-lsp-server && conda clean -afy

# # Switch to jovyan for user-level operations
# USER jovyan
# RUN mkdir -p /home/jovyan/.jupyter/lab/user-settings/@krassowski/jupyterlab-lsp
# COPY --chown=jovyan:users docker/jupyterlab-lsp-settings.json /home/jovyan/.jupyter/lab/user-settings/@krassowski/jupyterlab-lsp/plugin.jupyterlab-settings

RUN ln -sv / .lsp_symlink

RUN fix-permissions $CONDA_DIR \
    && fix-permissions /home/$NB_USER