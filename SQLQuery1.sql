use Hospital

--Q1
Begin Transaction
Update Patients set WardId=2
where id=1
Commit Transaction

--Q2
Begin Transaction
Update Consultants set Salary=Salary+5000
where id=1
RollBack Transaction

--Q3
Begin Transaction
Update Patients set WardId=3
where id=1

Update Nurses set ServesInWardId=3
where Number=1
Commit Transaction

--Q4
Begin Transaction
Update Patients set WardId=2
where id=1

Save Transaction PatientUpdate
Update Patients set Name='Temporary Patient Name'
where id=1
RollBack Transaction PatientUpdate
Commit Transaction

--Q5
Begin Try
Begin Transaction
Update Consultants set Salary=Salary+3000
where id=1
Commit Transaction
End Try
Begin Catch
if @@TRANCOUNT>0
RollBack Transaction
Select Error_Number() ErrorNumber,
Error_Message() ErrorMessage
End Catch

--Q6
Go
Create Or Alter view VW_ConsultantPatientStatistics
with Encryption 
As
select c.Id CId,c.Name CName,c.Salary CSalary,Count(c.Id) CountOfPatients
from PatientConsultantAssignments Pc join Consultants c
on pc.ConsultantId=c.Id
Group By c.Id ,c.Name,c.Salary

--Q7
select * from VW_ConsultantPatientStatistics
where CountOfPatients>5

--Q8
Create Or Alter view dbo.VW_IndexedConsultantPatientCount
with SchemaBinding
As
select ConsultantId,COUNT_BIG(*) CountOfPatient
from dbo.PatientConsultantAssignments
Group By ConsultantId

Create Unique Clustered Index IX_ClusteredIdx
on dbo.VW_IndexedConsultantPatientCount(ConsultantId)

--Q9
select * from dbo.VW_IndexedConsultantPatientCount
where CountOfPatient>5

--Q10
Select
    Name AS ViewName,
    Create_Date AS CreationDate,
    Modify_Date AS ModificationDate
From sys.views

--Q11
Create Or Alter view VW_PatientInformation
As
select  Id PId,Name PName,WardId  WId
from Patients

Exec sp_helptext 'VW_PatientInformation'

--Q12
Create Or Alter view VW_PatientInformation
As
select  Id PId,Name PName,DOB DOB
from Patients

--Q13
Create Or Alter view VW_ConsultantSalary
As
select Salary
from Consultants

Drop View VW_ConsultantSalary

--Q14
Create Or Alter view VW_PatientHospitalReport
As
select p.Id PId,p.Name PName, p.DOB DOB, w.Name WName ,c.Name CName
from Patients p left Join PatientConsultantAssignments PA
on p.Id=PA.PatientId
left Join Wards w
on p.WardId=w.Id        
left join Consultants c
on c.Id=PA.ConsultantId

--Q15
select * from VW_PatientHospitalReport
where CName is Not Null

--Q16
select PName,WName,CName
from VW_PatientHospitalReport
where WName ='Cardiology'

--Q17
select Top(1) * from VW_ConsultantPatientStatistics
Order By CountOfPatients Desc

--Q18
Create Or Alter view VW_PatientAgeInformation
As
select Id PId, Name PName, DOB , DATEDIFF(YEAR, DOB, GETDATE()) Age
from Patients

select * from VW_PatientAgeInformation
where Age >60

--Q19
select * from VW_ConsultantPatientStatistics
Order By CountOfPatients desc

--Q20
Create Or Alter View VW_PatientWardInformation
As
select w.Name,COUNT(p.WardId) CountOFPatients
from Wards w join Patients p
on p.WardId=w.Id
Group By w.Name

select * From VW_PatientWardInformation

--Q21
Select
    S.Name AS SchemaName,
    V.Name AS ViewName,
    I.Name AS IdexName,
    I.Type_Desc AS IdexType
From sys.views V
Join sys.indexes I
    On V.Object_Id = I.Object_Id
Join sys.schemas S
    On V.Schema_Id = S.Schema_Id
Where I.Index_Id > 0

Go