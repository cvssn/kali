/* dados e funções alpine.js chamados do modelo de navegação principal */

function alpineCore() {
    return {
        openTabs: [],
        activeTabIndex: 0,
        errors: startupErrors,
        showErrors: false,
        version: '0.0.0',
        isFirstVisit: false,
        scrollTop: window.scrollY,

        initPage() {
            window.onscroll = () => {
                this.scrollTop = window.scrollY;
            };

            apiV2('GET', '/api/v2/health').then((response) => {
                this.version = response.version;

                this.checkIfFirstVisit();
            }).catch((error) => {
                console.error(error);

                toast('erro ao carregar a página', false);
            });
        },

        checkIfFirstVisit() {
            let localStorage = window.localStorage;

            this.isFirstVisit = !localStorage.getItem('firstVisit');

            if (this.isFirstVisit) {
                localStorage.setItem('firstVisit', new Date().toISOString());
            }
        },

        setTabContent(tab, html) {
            const newTabDiv = document.createElement('div');

            newTabDiv.setAttribute('id', tab.contentID);
            newTabDiv.setAttribute('x-show', 'openTabs[activeTabIndex] && openTabs[activeTabIndex].contentID === $el.id');

            setInnerHTML(newTabDiv, html);

            document.getElementById('active-tab-display').appendChild(newTabDiv);
        },

        async addTab(tabName, address, queryString = '') {
            // manual de campo não cria aba
            if (tabName === 'fieldmanual') {
                restRequest('GET', null, (data) => { this.setTabContent({ name: tabName, contentID: `tab-${tabName}`, address: address }, data); }, address);
                
                return;
            }

            // se a guia já estiver aberta, vá até ela
            const existingTabIndex = this.openTabs.findIndex((tab) => tab.name === tabName);

            if (existingTabIndex !== -1) {
                this.activeTabIndex = existingTabIndex;

                this.checkQueryString(queryString);

                return;
            }

            // guia não existe, crie-a
            const tab = { name: tabName, contentID: `tab-${tabName}`, address: address };

            this.openTabs.push(tab);
            this.activeTabIndex = this.openTabs.length - 1;

            try {
                this.setTabContent(tab, await apiV2('GET', tab.address));

                this.checkQueryString(queryString);
            } catch (error) {
                toast('não foi possível carregar a página', false);

                console.error(error);
            }
        },

        checkQueryString(queryString) {
            if (history.pushState) {
                const newurl = `${window.location.protocol}//${window.location.host}${window.location.pathname}?${queryString}${window.location.hash}`;
                
                window.history.replaceState({ path: newurl }, "", newurl);
            } else {
                window.location.search = queryString;
            }
        },

        deleteTab(index, contentID) {
            try {
                document.getElementById(contentID).remove();
            } catch (error) {
                // não faz nada
            }

            if (this.activeTabIndex >= index) {
                this.activeTabIndex = Math.max(0, this.activeTabIndex - 1);
            }

            this.openTabs.splice(index, 1);
        }
    };
}