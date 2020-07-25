({
    validateResponse: function (response) {
        let flag = true;
        const state = response.getState();
        if (state === 'SUCCESS') {
            return flag;
        } else if (state === 'ERROR') {
            flag = false;
            const errors = response.getError();
            let errorMessage = "Unknown error";
            if (errors && errors[0] && errors[0].message) {
                errorMessage = errors[0].message;
            }
            console.error(errorMessage);
            return flag;
        }
        return flag;
    },

    navigateToUrl: function (component, event, returnValue) {
        const obj = JSON.parse(returnValue);
        const nav = component.find("navService");
        let pageReference = {};
        if (obj[0].Admin__c === true) {
            pageReference = {
                type: 'standard__component',
                attributes: {
                    componentName: 'c__adminPage'
                },
                state: {
                    "c__userId": obj[0].Id,
                }
            };
        } else {
            pageReference = {
                type: 'standard__component',
                attributes: {
                    componentName: 'c__expensesPage'
                },
                state: {
                    "c__userId": obj[0].Id,
                    "c__office": obj[0].Office__c
                }
            };
        }
        nav.navigate(pageReference);
    }
})