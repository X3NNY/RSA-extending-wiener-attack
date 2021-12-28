
# set True to display details
debug = True

isdigit = lambda x: ord('0') <= ord(x) <= ord('9')

def my_permutations(g, n):
    sub = []
    res = []
    def dfs(s, prev):
        if len(s) == n:
            res.append(s[::])
        for i in g:
            if i in s or i < prev:
                continue
            s.append(i)
            dfs(s, max(prev, i))
            s.remove(i)
    dfs(sub, 0)
    return res

class X3NNY(object):
    def __init__(self, exp1, exp2):
        self.exp1 = exp1
        self.exp2 = exp2
    
    def __mul__(self, b):
        return X3NNY(self.exp1 * b.exp1, self.exp2 * b.exp2)

    def __repr__(self):
        return '%s = %s' % (self.exp1.expand().collect_common_factors(), self.exp2)

class X_Complex(object):
    def __init__(self, exp):
        i = 0
        s = '%s' % exp
        while i < len(s):
            if isdigit(s[i]):
                num = 0
                while i < len(s) and isdigit(s[i]):
                    num = num*10 + int(s[i])
                    i += 1
                if i >= len(s):
                    self.b = num
                elif s[i] == '*':
                    self.a = num
                    i += 2
                elif s[i] == '/':
                    i += 1
                    r = 0
                    while i < len(s) and isdigit(s[i]):
                        r = r*10 + int(s[i])
                        i += 1
                    self.b = num/r
            else:
                i += 1
        if not hasattr(self, 'a'):
            self.a = 1
        if not hasattr(self, 'b'):
            self.b = 0

def WW(e, d, k, g, N, s):
    return X3NNY(e*d*g-k*N, g+k*s)
def GG(e1, e2, d1, d2, k1, k2):
    return X3NNY(e1*d1*k2- e2*d2*k1, k2 - k1)

def W(i):
    e = eval("e%d" % i)
    d = eval("d%d" % i)
    k = eval("k%d" % i)
    return WW(e, d, k, g, N, s)

def G(i, j):
    e1 = eval("e%d" % i)
    d1 = eval("d%d" % i)
    k1 = eval("k%d" % i)
    
    e2 = eval("e%d" % j)
    d2 = eval("d%d" % j)
    k2 = eval("k%d" % j)
    
    return GG(e1, e2, d1, d2, k1, k2)

def R(e, sn): # min u max v
    ret = X3NNY(1, 1)
    n = max(e)
    nn = len(e)
    l = set(i for i in range(1, n+1))
    d = ''
    u, v = 0, 0
    for i in e:
        if i == 1:
            ret *= W(1)
            d += 'W(%d)' % i
            nn -= 1
            l.remove(1)
            u += 1
        elif i > min(l) and len(l) >= 2*nn:
            ret *= G(min(l), i)
            nn -= 1
            d += 'G(%d, %d)' % (min(l), i)
            l.remove(min(l))
            l.remove(i)
            v += 1
        else:
            ret *= W(i)
            l.remove(i)
            d += 'W(%d)' % i
            nn -= 1
            u += 1
    if debug:
        print(d)
    return ret, u/2 + (sn - v) * a

def H(n):
    if n == 0:
        return [0]
    if n == 2:
        return [(), (1,), (2,), (1, 2)]
    ret = []
    for i in range(3, n+1):
        ret.append((i,))
        for j in range(1, i):
            for k in my_permutations(range(1, i), j):
                ret.append(tuple(k + [i]))
    return H(2) + ret
    
def CC(exp, n):
    cols = [0 for i in range(1<<n)]
    
    # split exp
    texps = ('%s' % exp.exp1.expand()).strip().split(' - ')
    ops = []
    exps = []
    for i in range(len(texps)):
        if texps[i].find(' + ') != -1:
            tmp = texps[i].split(' + ')
            ops.append(0)
            exps.append(tmp[0])
            for i in range(1, len(tmp)):
                ops.append(1)
                exps.append(tmp[i])
        else:
            ops.append(0)
            exps.append(texps[i])
    if exps[0][0] == '-':
        for i in range(len(exps)):
            ops[i] = 1-ops[i]
        exps[0] = exps[0][1:]
    else:
        ops[0] = 1
    # find e and N
    l = []
    for i in range(len(exps)):
        tmp = 1 if ops[i] else -1
        en = []
        j = 0
        while j < len(exps[i]):
            if exps[i][j] == 'e':
                num = 0
                j += 1
                while isdigit(exps[i][j]):
                    num = num*10 + int(exps[i][j])
                    j += 1
                tmp *= eval('e%d' % num)
                en.append(num)
            elif exps[i][j] == 'N':
                j += 1
                num = 0
                if exps[i][j] == '^':
                    j += 1
                    while isdigit(exps[i][j]):
                        num = num*10 + int(exps[i][j])
                        j += 1
                if num == 0:
                    num = 1
                tmp *= eval('N**%d' % num)
            else:
                j += 1
        if tmp == 1 or tmp == -1:
            l.append((0, ()))
        else:
            l.append((tmp, tuple(sorted(en))))
    
    # construct h
    mp = H(n)
    for val, en in l:
        cols[mp.index(en)] = val
    # print(cols)
    return cols

def stirling(k):
    return factorial(k)/(factorial(k//2)^2)
def calcAlpha(n):
    if n % 2 == 1:
        fz = (2*n + 1) * 2^n - 4*n*stirling(n-1)
        fm = (2*n - 2) * 2^n + 8*n*stirling(n-1)
    else:
        fz = (2*n + 1) * 2^n - (2*n + 1)*stirling(n)
        fm = (2*n - 2) * 2^n + (4*n + 2)*stirling(n)
    return fz/fm


def EWA(n, elist, NN, alpha):
    mp = H(n)
    var('a')
    S = [X_Complex(n*a)]
    cols = [[1 if i == 0 else 0 for i in range(2^n)]]
    for i in mp[1:]:
        eL, s = R(i, n)
        cols.append(CC(eL, n))
        S.append(X_Complex(s))
    
    alphaA,alphaB = 0, 0
    for i in S:
        alphaA = max(i.a, alphaA)
        alphaB = max(i.b, alphaB)
    D = []
    for i in range(len(S)):
        D.append(
            int(NN^((alphaA-S[i].a)*alpha + (alphaB - S[i].b)))
        )
    kw = {'N': NN}
    for i in range(len(elist)):
        kw['e%d' % (i+1)] = elist[i]
    if debug:
        print("The lattice: ")
        print(Matrix(cols).T)
        
        print("The matrix D: ")
        print([N^((alphaA-S[i].a)*alpha + (alphaB - S[i].b)) for i in range(len(S))])

    B = Matrix(ZZ, Matrix(cols).T(**kw)) * diagonal_matrix(ZZ, D)
    L = B.LLL(0.5)
    v = Matrix(ZZ, L[0])
    x = v * B**(-1)
    phi = int(x[0,1]/x[0,0]*elist[0])
    return phi

def attack(NN, elist, alpha):
    for i in range(1, len(elist)+1):
        var("e%d" % i)
        var("d%d" % i)
        var("k%d" % i)
    g, N, s = var('g'), var('N'), var('s')
    phi = EWA(len(elist), elist, NN, alpha)
    return phi

def example():
    from Crypto.Util.number import long_to_bytes, getPrime, bytes_to_long
    import uuid
    def rsa(e, n):
        m = bytearray.fromhex("00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000045F22F0AE9FF2248CFA7E0884986D743BAB009BAEA71AC9C32658C307A95DFD2")
        c = pow(bytes_to_long(m), e, n)
        return m, c
    
    # The modulus in RSA
    NN = bytes_to_long(bytearray.fromhex("D54FFF9517E8CE058495B676FB8E7BB93E3C09766FB4CC16AA1AFD1B589119B21A0B150666C452378933EEA701BD30D608CFF16267BDCC9A0C41A5675B65386B409085EF77D32640E1DD98CB85CC6E78AA29EAE44D41E7288E0B58398BF85822B780A42DA1968D246BD2262B816251D358C58DBEAE4DB656089DFF7E241A460321D299F59477E6CF1C3C1C7DF8F249FE4E42B1FEC35356522FFD301E722D57BBF4179CFDA1E990F7476D9857AE4845E07F233AF626D37EF023EDED0124627A23917129E4B792830BB4F5D25DE438EA2E102C33068A3074BBB5DAACF3E1786B9D80BF343763AA3D65B755C9425016FC0937305F56ED9E24DC0F29C44DD15C0735"))
    
    # The exponent in RSA
    e = 0x3
    m, c = rsa(e, NN)
    print("The plaintext is:", m.hex())
    
    # Theoretical upper bound in paper, but it is much smaller when actual test 
    alpha = calcAlpha(3)
    print("Alpha: ",alpha)
    elist = [int(inverse_mod(getPrime(int(alpha * NN.bit_length())), (p-1) * (q-1))) for i in range(3)]
    phi = attack(NN, elist, alpha)
    
    if phi != 0:
        print("Found Phi: ", phi)
        d = inverse_mod(e, phi)
        print("Bingo!The message is: ", long_to_bytes(pow(c, d, NN)).hex())

if __name__ == "__main__":
    example()
