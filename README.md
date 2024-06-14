# test-subworkflow-remote
This is a dummy repository to simulate an nf-core structured remote in another organization

It serves to show how, currently, you cannot install a subworkflow from a remote that uses
modules from more than one remote.

The error in its current state is better described by the following issues:

- [nf-core/tools#1927](https://github.com/nf-core/tools/issues/1927) - **Subworkflows can only use modules present in the same repo**
- [nf-core/tools#2497](https://github.com/nf-core/tools/issues/2497) -  **Installing missing modules from other repos**

## Reproducing the error

1. Install nf-core tools

```bash
pip install nf-core
```

2. Create a new Nextflow pipeline with the nf-core template

```bash
nf-core create --name test --plain --description test --author test
```

3. Inside your newly-created pipeline, you can download the `passing` subworkflow from this repository, which only contain local modules, and therefore works:

```bash
nf-core subworkflows --git-remote https://github.com/jvfe/test-subworkflow-remote install passing
```

4. Alternatively, attempt to download the `HIC_BWAMEM2` subworkflow, using this repository as your remote.

```bash
nf-core subworkflows --git-remote https://github.com/jvfe/test-subworkflow-remote install HIC_BWAMEM2
```

This will give you an error related to the `samtools/merge` module, which is not present in this repository.

> [!NOTE]
> The code inside the subworkflows is non-functional and serves merely to demonstrate the error.
