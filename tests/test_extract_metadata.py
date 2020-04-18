import lambdas.extract_metadata.extract_metadata as em


def test_save_metadata_to_s3():
    print(em.save_metadata_to_s3)


def test_extract_metadata():
    print(em.extract_metadata)


def test_save_file_to_filesystem():
    print(em.save_file_to_filesystem)


def test_handler():
    print(em.handler)
