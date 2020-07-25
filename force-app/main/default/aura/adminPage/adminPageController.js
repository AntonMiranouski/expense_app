({
    init: function (component, event, helper) {

        const year = new Date().getFullYear();
        component.set("v.year", year);

        const years = [];
        for (let i = -2; i <= 1; i++) {
            years.push({
                label: 'Regional Expenses ' + (new Date().getFullYear() + i).toString(),
                value: new Date().getFullYear() + i
            });
        }
        component.set("v.years", years);

        helper.getExpenses(component, year);
    },

    yearChanged: function (component, event, helper) {
        const year = event.getParam("value");
        console.log(year);
        component.set("v.year", year);

        helper.getExpenses(component, year);
    },

    navigateToOffice: function (component, event, helper) {
        const nav = component.find("adminNavService");
        const office = event.target.dataset.menuItemId;
        console.log('Navigate to expense cards of ' + office);
        const pageReference = {
            type: 'standard__component',
            attributes: {
                componentName: 'c__expensesPage'
            },
            state: {
                "c__office": office,
                "c__userId": component.get("v.pageReference").state.c__userId
            }
        };
        event.preventDefault();
        nav.navigate(pageReference);
    },
})