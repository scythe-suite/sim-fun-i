load test_helper

teardown() {
    rm -f *.class actual-*.txt errors-*.txt diffs-*.txt
}

@test "compiling 'empty' (missing source)" {
  cd fixtures/empty
  run sf compile
  [ "$status" -eq 1 ]
  [[ ${lines[0]} =~ .*"No source file found".* ]]
}

@test "compiling 'sum' (a correct program)" {
  cd fixtures/java/sum
  run sf compile
  [ "$status" -eq 0 ]
  [[ ${lines[0]} =~ .*"Using processor: JavaSolution".* ]]
  [[ ${lines[1]} =~ .*"Succesfully compiled sources: Solution.java".* ]]
}

@test "compiling 'sum_mismatch' (public class, file/class name mismatch)" {
  cd fixtures/java/sum_mismatch
  run sf compile
  [ "$status" -eq 1 ]
  [[ ${lines[2]} =~ .*"Nope.java:3: error: class Solution is public, should be declared in a file named Solution.java".* ]]
}

@test "compiling 'sum_nonpublic' (non public class)" {
  cd fixtures/java/sum_nonpublic
  run sf compile
  [ "$status" -eq 0 ]
  [[ ${lines[0]} =~ .*"Using processor: JavaSolution".* ]]
  [[ ${lines[1]} =~ .*"Succesfully compiled sources: Solution.java".* ]]
}

@test "compiling 'sum_nomain' (public class, no main method)" {
  cd fixtures/java/sum_nomain
  run sf compile
  [ "$status" -eq 1 ]
  [[ ${lines[0]} =~ .*"No source file found".* ]]
}

@test "generating 'sum' output" {
  cd fixtures/java/sum
  run sf generate -f
  [ "$status" -eq 0 ]
  [ -r expected-1.txt ]
  [ -r expected-2.txt ]
  [ ! -r args-1.txt ]
  [ ! -r args-2.txt ]
  [[ ${lines[0]} =~ .*"Using processor: JavaSolution".* ]]
  [[ ${lines[1]} =~ .*"Succesfully compiled sources: Solution.java".* ]]
  [[ ${lines[2]} =~ .*"Generated expected output for cases: 1, 2".* ]]
}

@test "testing 'sum' output" {
  cd fixtures/java/sum
  sf generate -f
  run sf test -f
  [ ! -r diffs-1.txt ]
  [ ! -r diffs-2.txt ]
  [ ! -r errors-1.txt ]
  [ ! -r errors-2.txt ]
  rm -f expected-*.txt
  [ "$status" -eq 0 ]
  [[ ${lines[0]} =~ .*"Using processor: JavaSolution".* ]]
  [[ ${lines[1]} =~ .*"Succesfully compiled sources: Solution.java".* ]]
  [[ ${lines[2]} =~ .*"Generated actual output for cases: 1, 2".* ]]
  [[ ${lines[3]} =~ .*"Cases run with no diffs or errors".* ]]
}

@test "diffing 'sum_diff' differences" {
  cd fixtures/java/sum_diffs
  run sf test -f
  [ -r diffs-1.txt ]
  [ -r diffs-2.txt ]
  [ ! -r errors-1.txt ]
  [ ! -r errors-2.txt ]
  echo "${lines[5]}" | nl -v0 > /tmp/out
  echo "$output" | nl -v0 >> /tmp/out
  [ "$status" -eq 0 ]
  [[ ${lines[0]} =~ .*"Using processor: JavaSolution".* ]]
  [[ ${lines[1]} =~ .*"Succesfully compiled sources: Solution.java".* ]]
  [[ ${lines[2]} =~ .*"Generated actual output for cases: 1, 2".* ]]
  [[ ${lines[3]} =~ .*"Case 1 returned the following diffs:".* ]]
  [[ ${lines[11]} =~ .*"Case 2 returned the following diffs:".* ]]
}