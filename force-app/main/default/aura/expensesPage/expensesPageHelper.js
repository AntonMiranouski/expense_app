({
    getExpenses: function (component, selectedDate) {
        if (selectedDate === null) {
            var today = new Date();
            var month = today.getMonth() + 1;
            if (month < 10) {
                month = '0' + month;
            }
            selectedDate = today.getFullYear() + '-' + month + '-01';
            component.set("v.selectedDate", selectedDate);
        }

        var action = component.get("c.getExpenseCard");
        var id = component.get("v.userId", id);
        if (id === undefined) {
            id = null;
        }
        var office = component.get("v.office", office);
        if (office === undefined) {
            office = null;
        }

        action.setParams({
            conId: id,
            selectedDate: selectedDate,
            office: office
        });

        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var expensesCard = [];
                expensesCard = response.getReturnValue();
                component.set("v.expenseCard", expensesCard);
                component.set("v.isDataChanged", false);
            }
        });
        $A.enqueueAction(action);
    },

    getMonthlyExpense: function (component, selectedDate) {
        var action = component.get("c.getMonthlyExpense");
        var id = component.get("v.userId", id);
        if (id === undefined) {
            id = null;
        }
        var office = component.get("v.office", office);
        if (office === undefined) {
            office = null;
        }

        action.setParams({
            conId: id,
            selectedDate: selectedDate,
            office: office
        });

        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var monthlyExpense = [];
                monthlyExpense = response.getReturnValue();
                component.set("v.monthlyExpense", monthlyExpense);
                component.set("v.isDataChanged", false);
            }
        });
        $A.enqueueAction(action);
    },

    saveChanges: function (component, draftValues) {
        var changes = [];
        draftValues.forEach(function (row) {
            const change = {
                cardId: row.Id,
                description: row.Description__c,
                amount: row.Amount__c
            };
            changes.push(change);
        });

        let action = component.get("c.updateExpenseCard");
        action.setParams({
            cardId: changes[0].cardId,
            description: changes[0].description,
            amount: changes[0].amount
        });

        if (changes[0].description === undefined) {
            changes[0].description = 'null';
        } else if (changes[0].amount === undefined) {
            changes[0].amount = 'null';
        }

        action.setCallback(this, function (response) {
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
})