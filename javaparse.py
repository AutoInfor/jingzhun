import javalang
import time
import collections
def git_parse():
    fd = open("./MainActivity.java", "r", encoding="utf-8")
    treenode = javalang.parse.parse(fd.read())
    start = time.time()
    method_list=[]
    classname=''
    print(treenode)
    for path, node in treenode:
        if isinstance(node, javalang.tree.ClassDeclaration):
            if not classname:
                classname=node.name
            if classname!=node.name:
                classname='$'+node.name
            
            for path1, node1 in node:
                if isinstance(node1, javalang.tree.MethodDeclaration):
                    path_list=[]
                    for i in node1.body:
                        if isinstance(i, javalang.tree.StatementExpression) or isinstance(i, javalang.tree.LocalVariableDeclaration):
                            for path3, node3 in i: 
                                if isinstance(node3, javalang.tree.MethodInvocation) or isinstance(node3, javalang.tree.SuperMethodInvocation):
                                    path_list.append(node3.member)
                                    break
                    method_list.append((classname+'.'+node1.name,(node1.position[0],node1._end_position[0]),path_list))
                    
                    
                    for path2, node2 in node1:
                        if isinstance(node2, javalang.tree.BlockStatement):
                            path_list=[]
                            for i in node2.statements:
                                if isinstance(i, javalang.tree.StatementExpression) or isinstance(i, javalang.tree.LocalVariableDeclaration):
                                    for path3, node3 in i: 
                                        if isinstance(node3, javalang.tree.MethodInvocation) or isinstance(node3, javalang.tree.SuperMethodInvocation):
                                            path_list.append(node3.member)
                                            break
                            
                            method_list.append((classname+'.'+node1.name,(node2.position[0],node2._end_position[0]),path_list))
                            continue
                #continue
    print(time.time()-start)
    print(sorted(method_list,key=lambda x:x[1][1]-x[1][0]))
    return treenode.package.name,sorted(method_list,key=lambda x:x[1][1]-x[1][0])

git_parse()   
