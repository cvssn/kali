#!/usr/bin/env python3

# nota: esse script roda theHarvester

import sys

from theHarvester.theHarvester import main


if sys.version_info.major < 3 or sys.version_info.minor < 9:
    print('\033[93m[!] certifique-se de que você tenha o python 3.9+ instalado, encerrando.\n\n \033[0m')
    
    sys.exit(1)

if __name__ == '__main__':
    main()