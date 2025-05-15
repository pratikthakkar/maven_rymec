package com.example.student;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Controller
public class StudentController {

    @Autowired
    private StudentRepository studentRepository;

    @GetMapping("/")
    public String showForm(Model model) {
        model.addAttribute("student", new Student());
        return "index";
    }

    @PostMapping("/submit")
    public String submitPercentage(@ModelAttribute Student student, Model model) {
        Student savedStudent = studentRepository.save(
            new Student(student.getName(), student.getSem(), student.getPercentage())
        );
        model.addAttribute("result", savedStudent.getResult());
        model.addAttribute("percentage", savedStudent.getPercentage());
        model.addAttribute("name", savedStudent.getName());
        model.addAttribute("sem", savedStudent.getSem());
        return "result";
    }

    @GetMapping("/students")
    public String listStudents(Model model) {
        List<Student> students = studentRepository.findAll();
        model.addAttribute("students", students);
        return "students";
    }
}
