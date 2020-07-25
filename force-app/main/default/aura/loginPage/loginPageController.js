({
    onclick: function (component, event, helper) {
        const action = component.get("c.login");
        const email = component.get("v.email");
        const password = component.get("v.password");
        action.setParams({
            email: email,
            password: password
        });
        action.setCallback(this, function (response) {
            var returnValue = response.getReturnValue();
            if (helper.validateResponse(response)) {
                if (returnValue.startsWith('[{"attributes"')) {
                    helper.navigateToUrl(component, event, returnValue);
                } else {
                    component.set("v.isErrorHidden", false);
                    component.set("v.errorMessage", returnValue);
                }
            } else {
                component.set("v.isErrorHidden", false);
                component.set("v.errorMessage", returnValue);
            }
        });
        $A.enqueueAction(action);
    }
})