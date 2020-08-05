({
    save: function (component, event, helper) {
        const action = component.get("c.saveExpenseCard");
        const conId = component.get("v.userId");
        const amount = component.get("v.amount");
        const cardDate = component.get("v.cardDate");
        const description = component.get("v.description");
        const office = component.get("v.office");
       
        action.setParams({
            conId: conId,
            amount: amount,
            cardDate: cardDate,
            description: description,
            office: office
        });
        
        action.setCallback(this, function (response) {
            console.log(response.getState());
            if (response.getState() === "SUCCESS") {
                component.set("v.isShownNewCardWizard", false);
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
        component.set("v.isShownNewCardWizard", false);
    }
})