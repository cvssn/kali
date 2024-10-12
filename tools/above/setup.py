from setuptools import setup, find_packages


setup(
    name="above",
    version="2,7",
    url="https://github.com/cvssn/kali/tools/above",
    author="cavassani",
    author_email="cavassani.me@gmail.com",
    scripts=['above.py'],
    description="sniffer de procolo de network invisível",
    long_description=open('README.md').read(),
    long_description_content_type='text/markdown',
    license="Apache-2.0",
    keywords=['segurança de network', 'sniffer de network'],
    packages=find_packages(),
    
    install_requires=[
        'scapy',
        'colorama'
    ],
    
    entry_points={
        "console_scripts": ["above = above:main"]
    },
    
    python_requires='>=3.11'
)