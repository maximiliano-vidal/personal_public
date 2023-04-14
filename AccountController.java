package com.edsa.factory.api.controllers;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.data.domain.Sort.Direction;
import org.springframework.data.domain.Sort.Order;
import org.springframework.data.rest.webmvc.json.patch.BindContext;
import org.springframework.data.rest.webmvc.json.patch.JsonPatchPatchConverter;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.edsa.factory.api.dtos.AccountFilterDto;
import com.edsa.factory.model.entities.Account;
import com.edsa.factory.model.filters.AccountFilter;
import com.edsa.factory.model.repositories.AccountRepository;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fwk.arqrestapis.io.PagedResult;

import jakarta.validation.Valid;
import lombok.AllArgsConstructor;


@AllArgsConstructor
@RestController
public class AccountController {

	private JsonPatchPatchConverter patchConverter;
	
	private AccountRepository repository;
	
	@GetMapping("/api/accounts")
	public ResponseEntity<PagedResult<Account>> get(AccountFilterDto filter, @RequestParam Optional<Integer> page, @RequestParam Optional<Integer> size, @RequestParam(required=false) List<String> sort) {
		//Page<Account> data = this.repository.findAll(PageRequest.of(page.orElse(0), size.orElse(20), Sort.by(sort.stream().map(s->s.split("_")).map(a->Order.by(a[0]).with(Direction.valueOf(a[1].toUpperCase()))).collect(Collectors.toList()))));
		Pageable pageRequest = PageRequest.of(page.orElse(0), size.orElse(20), Sort.by(sort.stream().map(s->s.split("_")).map(a->Order.by(a[0]).with(Direction.valueOf(a[1].toUpperCase()))).collect(Collectors.toList())));
		
		AccountFilter criteria = null; //map from filter
		Page<Account> data = this.repository.findByFilters(criteria, pageRequest);
		
		
		
		return ResponseEntity.ok(PagedResult.of(data));
	}
	
	@GetMapping("/api/accounts/{id}")
	public ResponseEntity<Account> get(Long id) {
		Optional<Account> data = this.repository.findById(id);
		return data.map(ResponseEntity::ok).orElse(ResponseEntity.notFound().build());
	}

	@PostMapping("/api/accounts")
	public ResponseEntity<?> insert(@RequestBody @Valid Account data) {
		Account saved = this.repository.save(data);
		return ResponseEntity.status(HttpStatus.CREATED).body(saved);
	}

	@PutMapping("/api/accounts")
	public ResponseEntity<?> update(@RequestBody @Valid Account data) {
		if (!this.repository.findById(data.getId()).isPresent()) {
			return ResponseEntity.notFound().build();
		}
		this.repository.save(data);
		return ResponseEntity.ok().build();
	}

	@DeleteMapping("/api/accounts/{id}")
	public ResponseEntity<?> delete(Long id) {
		Optional<Account> data = this.repository.findById(id);
		if (!data.isPresent()) {
			return ResponseEntity.notFound().build();
		}
		this.repository.delete(data.get());
		return ResponseEntity.ok().build();
	}
	
	@PatchMapping(value = "/api/accounts/{id}", consumes="application/json-patch+json")
	public ResponseEntity<?> patch(Long id, @RequestBody JsonNode operations) {
		Optional<Account> data = this.repository.findById(id);
		if (!data.isPresent()) {
			return ResponseEntity.notFound().build();
		}
		Account patched = patchConverter.convert(operations).apply(data.get(), Account.class);
		this.repository.save(patched);
		return ResponseEntity.ok().build();
	}

}
