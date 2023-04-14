package com.edsa.factory.model.entities;

import java.util.Date;

import com.fwk.arqrestapis.entity.AuditableEntity;
import com.fwk.arqrestapis.entity.Versionable;

import jakarta.persistence.Cacheable;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Version;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.Data;
import lombok.EqualsAndHashCode;

@EqualsAndHashCode(of = "id", callSuper = false)
@Cacheable(true)
@Data
@Entity
public class Account extends AuditableEntity implements Versionable {

	private static final long serialVersionUID = -2837458023271276070L;

	@GeneratedValue(strategy = GenerationType.IDENTITY)
	@Id
	private Long id;

	@Size(max=250)
	@NotEmpty
	private String fieldOne;
	
	@Size(max=250)
	private String fieldTwo;
	
	private Date fieldThree;

	@NotNull
	private boolean enable = true;

	@Version
	private Integer version;

}
