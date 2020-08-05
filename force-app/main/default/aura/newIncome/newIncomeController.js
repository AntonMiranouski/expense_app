({
    add: function (component, event, helper) {
        const action = component.get("c.addBalance");
        const conId = component.get("v.userId");
        const amount = component.get("v.amount");
        const office = component.get("v.office");

        const months = {
            'January' : '01',
            'February' : '02',
            'March' : '03',
            'April' : '04',
            'May' : '05',
            'June' : '06',
            'July' : '07',
            'August' : '08',
            'September' : '09',
            'October' : '10',
            'November' : '11',
            'December' : '12'
        }
        const month = months[component.find("selectedMonth").get("v.value")];
        const selectedDate = component.find("selectedYear").get("v.value") + '-' + month + '-01';

        action.setParams({
            selectedDate: selectedDate,
            conId: conId,
            amount: amount,
            office: office
        });

        action.setCallback(this, function (response) {
            if (response.getState() === "SUCCESS") {
                component.set("v.isShownAddBalanceWizard", false);
                var cmpEvent = component.getEvent("newExpense");
                cmpEvent.fire();
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
    },

    hide: function (component, event, helper) {
        component.set("v.isShownAddBalanceWizard", false);
    }
})