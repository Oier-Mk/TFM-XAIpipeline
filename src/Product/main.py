from pydantic import BaseModel
import pandas as pd
from fastapi import FastAPI, Request, Form, Response
from fastapi.responses import HTMLResponse
from fastapi.templating  import Jinja2Templates

app = FastAPI()
templates = Jinja2Templates(directory="templates")


@app.get("/")
async def root():
    return {"The /sendApplication endpoint needs to be called with a POST request and should have all the required fields in the request body."}


@app.get("/applicationForm", response_class=HTMLResponse)
async def application_form(request: Request):
    return templates.TemplateResponse("form.html", {"request": request})



from pyCBA import predict, initialize
transactions, rules, weights = initialize("../data/Statlog_rCBA.csv", 0.7,0.01, 0.01)

@app.post("/sendApplication")
async def send_application(
    request: Request, 
    response: Response, 
    status: str = Form(...),
    duration: str = Form(...), 
    credit_history: str = Form(...),
    purpose: str = Form(...),
    credit_amount: str = Form(...),
    savings: str = Form(...),
    employment_since: str = Form(...),
    installment_rate: str = Form(...),
    debtors: str = Form(...),
    residence_since: str = Form(...),
    property: str = Form(...),
    age: str = Form(...),
    other_plans: str = Form(...),
    housing: str = Form(...),
    existing_credits: str = Form(...),
    job: str = Form(...),
    maintenance_people: str = Form(...),
    telephone: str = Form(...),
    foreign_worker: str = Form(...),
    gender: str = Form(...),
    marital_status: str = Form(...)
):

    df = pd.DataFrame({
        'Status.of.existing.checking.account': [status],
        'Duration.in.month': [duration],
        'Credit.history': [credit_history],
        'Purpose': [purpose],
        'Credit.amount': [credit_amount],
        'Savings.account.bonds': [savings],
        'Present.employment.since': [employment_since],
        'Installment.rate.in.percentage.of.disposable.income': [installment_rate],
        'Other.debtors...guarantors': [debtors],
        'Present.residence.since': [residence_since],
        'Property': [property],
        'Age.in.years': [age],
        'Other.installment.plans': [other_plans],
        'Housing': [housing],
        'Number.of.existing.credits.at.this.bank': [existing_credits],
        'Job': [job],
        'Number.of.people.being.liable.to.provide.maintenance.for': [maintenance_people],
        'Telephone': [telephone],
        'Foreign.worker': [foreign_worker],
        'Gender': [gender],
        'Marital.Status': [marital_status]
    })
    
    prediction, r = predict(transactions, rules, weights, df, True)
    print("Prediction:", prediction)
    print("Rules:", r)

    # pandas dataframe to json as csv
    r = r.to_dict('records')

    return {"Prediction": prediction, "Rules": r}
 