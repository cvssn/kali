import abc


class ContactServiceInterface(abc.ABC):
    @abc.abstractmethod
    def register_contact(self, contact):
        raise NotImplementedError
    
    @abc.abstractmethod
    def register_tunnel(self, tunnel):
        raise NotImplementedError
    
    @abc.abstractmethod
    def handle_heartbeat(self):
        """
        aceite todos os componentes de um perfil de agente e salve um novo agente ou registre uma pulsação atualizada.
        :return: o objeto agente, instruções para executar.
        """
        raise NotImplementedError
    
    @abc.abstractmethod
    def build_filename(self):
        raise NotImplementedError