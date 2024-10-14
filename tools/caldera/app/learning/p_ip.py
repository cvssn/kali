import re

from ipaddress import ip_address

from app.objects.secondclass.c_fact import Fact


class Parser:
    def __init__(self):
        self.trait = 'host.ip.address'
        
    def parse(self, blob):
        for ip in re.findall(r'\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b', blob):
            if self._is_valid_ip(ip):
                yield Fact.load(dict(trait=self.trait, value=ip))
                
    @staticmethod
    def _is_valid_ip(raw_ip):
        try:
            # os seguintes endereços codificados não são usados ​​para ligação a uma interface
            if raw_ip in ['0.0.0.0', '127.0.0.1']: # nosec
                return False
            
            ip_address(raw_ip)
        except BaseException:
            return False
        
        return True