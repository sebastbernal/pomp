library(pomp)
library(reshape2)
library(magrittr)

options(digits=3)

try(pompExample(gompertz,envir=3))
pompExample(gompertz)
show(gompertz)
print(gompertz@rmeasure)
print(gompertz@dmeasure)
print(gompertz@rprocess)

po <- gompertz
coef(po)
coef(po,transform=TRUE)
coef(po,c("r","X.0"))
coef(po,c("r","X.0"),transform=TRUE)
coef(po,c("r","K")) <- c(0.2,1)
coef(po)
coef(po,transform=TRUE)
guess <- coef(po)
coef(po) <- numeric(0)
coef(po,transform=TRUE) <- partrans(po,guess,dir='to')
coef(po) <- numeric(0)
coef(po,c("K","r","sigma","tau","X.0"),
     transform=TRUE) <- partrans(po,guess,dir='to')
coef(po) <- numeric(0)
coef(po,c("K","r","sigma","tau","X.0")) <- unname(guess)
coef(po) <- numeric(0)
coef(po) <- guess
guess["r"] <- 0

set.seed(5868684L)
simulate(gompertz,states=TRUE,obs=TRUE) %>% melt() %>% head()
pfilter(gompertz,Np=1000) -> pf
round(logLik(pf))
round(pf$loglik)
trajectory(gompertz) %>% melt() %>% head()

try(
    mf <- mif(
        po,
        start=guess,
        Nmif=5,Np=1000,
        transform=TRUE,
        ic.lag=1,var.factor=1,
        cooling.fraction=0.99^50,
        rw.sd=c(r=0.02,K=0.02)
    )
)

set.seed(93848585L)
mf <- mif(
          po,
          Nmif=5,Np=1000,
          transform=TRUE,
          ic.lag=1,var.factor=1,
          cooling.fraction=0.99^50,
          rw.sd=c(r=0.02,K=0.02)
          )
coef(mf,transform=TRUE)
coef(mf)
conv.rec(mf)
conv.rec(mf,transform=TRUE)
conv.rec(mf,c("loglik","r"))
try(conv.rec(mf,c("loglik","r"),transform=FALSE))
try(conv.rec(mf,c("loglik","r"),transform=TRUE))
conv.rec(mf,c("loglik","r"),transform=TRUE)
conv.rec(mf,c("loglik"),transform=TRUE)
conv.rec(mf,c("K"),transform=TRUE)

gg <- pomp(gompertz,skeleton=map(function(x,t,params,...){
  xx <- x["X"]*exp(params["r"]*(1-x["X"]/params["K"]))
  c(X=unname(xx))
}))
coef(gg,c("X.0","r")) <- c(1.5,3)
trajectory(gg,as.data.frame=TRUE,times=seq(0,10))

# test coercion in internals for one-d arrays
cc <- array(data=coef(gompertz),dim=5,dimnames=list(names(coef(gompertz))))
x0 <- init.state(gompertz,params=cc)
x <- rprocess(gompertz,xstart=x0,times=1:2,params=cc,offset=1)
x <- array(data=x,dim=1,dimnames=list(rownames(x)))
y <- rmeasure(gompertz,x=x,y=0,params=cc,times=2)
x <- array(data=x,dim=c(1,1,1,1,1),dimnames=list(rownames(x)))
y <- rmeasure(gompertz,x=x,y=0,params=cc,times=2)

gg <- pomp(gompertz,tcovar="ctime",
           covar=data.frame(ctime=time(gompertz),
                            time=seq_along(time(gompertz))))
try(simulate(gg,as.data.frame=TRUE,include.data=T))
