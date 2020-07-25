({
    init: function (component, event, helper) {
        const id = component.get("v.pageReference").state.c__userId;
        const office = component.get("v.pageReference").state.c__office;
        component.set("v.userId", id);
        component.set("v.office", office);

        const months = ["January", "February", "March", "April", "May", "June",
            "July", "August", "September", "October", "November", "December"
        ];
        component.set("v.months", months);

        const year = new Date().getFullYear();
        const years = [year - 2, year - 1, year, year + 1];
        component.set("v.year", year);
        component.set("v.years", years);

        component.set('v.columns', [
            { label: 'Description', fieldName: 'Description__c', editable: true },
            { label: 'Amount', fieldName: 'Amount__c', type: 'currency', fixedWidth: 120, editable: true },
            { label: 'Action', type: 'button', fixedWidth: 90, typeAttributes: { variant: 'base', label: 'Delete', name: 'delete', onclick: 'deleteExpenseCard' } }
        ]);

        var expensesCard = [];
        component.set("v.expenseCard", expensesCard);
        helper.getMonthlyExpense(component, year);
    },

    newExpenseCard: function (component, event, helper) {
        component.set("v.isShownNewCardWizard", true);
    },

    addBalance: function (component, event, helper) {
        component.set("v.isShownAddBalanceWizard", true);
    },

    handleDelete: function (component, event, helper) {
        if (window.confirm("Are you sure?")) {
            const row = event.getParam("row");
            const expenseCardId = row.Id;

            const action = component.get("c.deleteExpenseCard");
            action.setParams({
                expenseCardId: expenseCardId
            });
            action.setCallback(this, function (response) {
                console.log(response.getState());
                if (response.getState() === "SUCCESS") {
                    component.set("v.isDataChanged", true);
                } else if (response.getState() === "ERROR") {
                    var errors = action.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            alert(errors[0].message);
                        }
                    }
                }
            });
            $A.enqueueAction(action);
        }
    },

    showExpenseCard: function (component, event, helper) {
        let selectedDate = event.currentTarget.dataset.record;
        component.set("v.selectedDate", selectedDate);
        helper.getExpenses(component, selectedDate);
    },

    yearChanged: function (component, event, helper) {
        let year = event.getSource().get("v.label");
        component.set("v.year", year);
        helper.getMonthlyExpense(component, year);
    },

    handleUpdate: function (component, event, helper) {
        let draftValues = event.getParam('draftValues');
        helper.saveChanges(component, draftValues);
    },

    rerender: function (component, event, helper) {
        let selectedDate = component.get("v.selectedDate");
        helper.getExpenses(component, selectedDate);

        let year = component.get("v.year");
        helper.getMonthlyExpense(component, year);
    }
})