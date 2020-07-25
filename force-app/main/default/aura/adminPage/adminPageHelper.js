({
    getExpenses : function(component, year) {
        var action = component.get("c.getMonthlyExpense");
        action.setParams({
            selectedDate: year
        });
        
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var monthlyExpense = [];
                monthlyExpense = response.getReturnValue();
                component.set("v.monthlyExpense", monthlyExpense);
            }
        });
        $A.enqueueAction(action);
    }
})