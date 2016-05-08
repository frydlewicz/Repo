#!/usr/bin/perl

use Term::ANSIColor;

$repoName = '.repo';

################################

sub repoExists {
   if(-d $repoName) {
      return 1;
   }

   return 0;
}

sub openRepo {
   opendir $repoDir, $repoName;
   @repoFiles = readdir $repoDir;
}

sub closeRepo {
   closedir $repoDir;
}

################################

sub printHelp {
   print color 'yellow';
   print "q, quit - zamknij program\n";
   print "c, create - stwórz repozytorium\n";
   print "l, list - lista kopii\n";
   print "a, add - dodaj plik\n";
   print "r, restore - przywróć kopię\n";
   print "d, delete - usuń kopię\n";
   print "x, destroy - usuń repozytorium\n";
   print color 'reset';
}

################################

sub printList {
   openRepo;
   print "\nNr    Data kopii         Nazwa pliku\n";
   print "####################################\n";

   my $i = 1;
   foreach(@repoFiles) {
      my ($fileDate, $fileName) = ($_ =~ m/\.(\d+).(.+)/);
      if(!$fileDate || !$fileName) {
         next;
      }

      @dateArray = localtime($fileDate);
      print sprintf("%03d   ", $i++);
      print sprintf("%04d-%02d-%02d %02d:%02d   ", $dateArray[5]+1900, $dateArray[4]+1, $dateArray[3], $dateArray[2], $dateArray[1]);
      print $fileName . "\n";
   }

   print "\n";
   closeRepo;
}

################################

sub getRepoFile {
   my $number = $_[0];
   openRepo;

   my $i = 1;
   foreach(@repoFiles) {
      my ($fileDate, $fileName) = ($_ =~ m/\.(\d+).(.+)/);
      if(!$fileDate || !$fileName) {
         next;
      }

      if($number == $i++) {
         closeRepo;
         return ($repoName . '/' . $_, $fileName);
      }
   }

   closeRepo;
   return (0, 0);
}

################################

do {{
   printHelp;
   $input = <>;
   chomp $input;

   #############################

   if($input eq 'c' || $input eq 'create') {
      if(repoExists) {
         print "Repozytorium już istnieje!\n\n";
         next;
      }
      
      system "mkdir '$repoName'";
      print "Pomyślnie utworzono repozytorium.\n\n";
   }

   #############################

   elsif($input eq 'l' || $input eq 'list') {
      if(!repoExists) {
         print "Nie stworzono jeszcze repozytorium!\n\n";
         next;
      }
      
      printList;
   }

   #############################

   elsif($input eq 'a' || $input eq 'add') {
      if(!repoExists) {
         print "Nie stworzono jeszcze repozytorium!\n\n";
         next;
      }
      
      print "\nPodaj nazwę pliku:\n";
      my $fileName = <>;
      chomp $fileName;

      if(!(-e $fileName)) {
         print "Podany plik nie istnieje!\n\n";
         next;
      }

      my $fileDest = $repoName . '/.' . time . '.' . $fileName;
      system "cp -R '$fileName' '$fileDest'";
      print "Pomyślnie utworzono kopię.\n\n";
   }

   #############################

   elsif($input eq 'r' || $input eq 'restore') {
      if(!repoExists) {
         print "Nie stworzono jeszcze repozytorium!\n\n";
         next;
      }
      
      print "\nPodaj numer kopii:\n";
      my $number = <>;
      chomp $number;

      my ($fileDest, $fileName) = getRepoFile($number);
      if(!(-e $fileDest)) {
         print "Podany numer nie istnieje!\n\n";
         next;
      }

      system "cp -R '$fileDest' '$fileName'";
      print("Pomyślnie przywrócono z kopii.\n\n");
   }

   #############################

   elsif($input eq 'd' || $input eq 'delete') {
      if(!repoExists) {
         print "Nie stworzono jeszcze repozytorium!\n\n";
         next;
      }
      
      print "\nPodaj numer kopii:\n";
      my $number = <>;
      chomp $number;

      my ($fileDest, $fileName) = getRepoFile($number);
      if(!(-e $fileDest)) {
         print "Podany numer nie istnieje!\n\n";
         next;
      }

      system "rm -Rf '$fileDest'";
      print("Pomyślnie usunięto kopię.\n\n");
   }
   
   #############################

   elsif($input eq 'x' || $input eq 'destroy') {
      if(!repoExists) {
         print "Nie stworzono jeszcze repozytorium!\n\n";
         next;
      }
      
      print "\nNa pewno chcesz usunąć całe repozytorium? [T - tak]\n";
      my $answer = <>;
      chomp $answer;
      
      if(!($answer eq 'T')) {
         print "\n";
         next;
      }

      system "rm -Rf '$repoName'";
      print("Pomyślnie usunięto repozytorium.\n\n");
   }
}}
until($input eq 'q' || $input eq 'quit');
print "\n";
